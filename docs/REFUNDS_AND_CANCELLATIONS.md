# Refunds and Subscription Cancellations

## Course Purchase Refunds

### Initiating a refund

Refunds for one-time course purchases are initiated from the admin area:

**URL:** `/admin/orders/:id` → "Refund" button

**Requirements:**
- Order must be in `paid` status
- Order must have a `stripe_payment_intent_id`

### Refund flow

1. Admin clicks "Refund" on the order detail page
2. `RefundService` creates a Stripe refund via `Stripe::Refund.create`
3. Order is updated: `status: "refunded"`, `refunded_at` set
4. `EnrollmentService.revoke_enrollments!` marks all related enrollments as `refunded` and sets `revoked_at`
5. `EnrollmentMailer.course_revoked` email is sent to the user
6. If a Fakturoid invoice exists, `FakturoidCorrectionJob` is enqueued to create a correction invoice

### Webhook-driven refund

If a refund is initiated directly in the Stripe Dashboard:
1. Stripe fires `charge.refunded` webhook
2. `WebhookProcessorService#handle_charge_refunded` processes it
3. Same flow as above: order → refunded, enrollments → revoked, Fakturoid correction created

### Idempotency

Both paths check `order.status == "refunded"` to avoid double-processing.

## Subscription Cancellation

### User-initiated cancellation

Users can cancel their subscriptions from the user area:

**URL:** `/user/subscriptions` → "Zrušit předplatné" button

### Cancellation flow

1. User clicks "Zrušit předplatné" (with confirmation dialog)
2. `UserArea::SubscriptionsController#cancel` calls `Stripe::Subscription.update(id, cancel_at_period_end: true)`
3. Local `Subscription` record is updated: `cancel_at_period_end: true`
4. **Access continues** until `current_period_end`
5. At period end, Stripe fires `customer.subscription.deleted`
6. `WebhookProcessorService#handle_subscription_deleted` sets `status: "canceled"`
7. `SubscriptionMailer.subscription_canceled` email is sent

### Resuming a canceled subscription

Before the period ends, users can reverse the cancellation:

1. User clicks "Obnovit" button on the subscriptions page
2. `UserArea::SubscriptionsController#resume` calls `Stripe::Subscription.update(id, cancel_at_period_end: false)`
3. Local record updated: `cancel_at_period_end: false`
4. Subscription continues as normal

### Access model

| Status       | Access? | Notes                                    |
|-------------|---------|------------------------------------------|
| active      | Yes     | Normal active subscription               |
| past_due    | Yes     | Payment failed, Stripe is retrying       |
| incomplete  | No      | Initial payment not yet completed        |
| canceled    | No      | Subscription ended                       |
| unpaid      | No      | All payment retries exhausted            |

Access is determined by `subscription.access_granted?` which returns `true` for `active` and `past_due` statuses.

### Payment failure handling

When a subscription payment fails:
1. Stripe fires `invoice.payment_failed`
2. `SubscriptionMailer.payment_failed` email is sent to the user
3. Stripe automatically retries the payment (configurable in Stripe Dashboard under Smart Retries)
4. During retries, subscription status is `past_due` — user retains access
5. If all retries fail, Stripe fires `customer.subscription.deleted` and access is revoked

### No partial refunds for subscriptions

Subscription cancellation is not a refund — the user keeps access until the end of the paid period. There is no prorated refund mechanism. If a manual refund is needed for a subscription payment, it can be done directly in the Stripe Dashboard; the `invoice.paid` order record serves as the accounting trail.

## Accounting Trail

### One-time purchases
- Order with `order_type: "one_time"`
- Fakturoid invoice created on payment
- Fakturoid correction invoice created on refund

### Subscription payments
- Order with `order_type: "subscription"` created on each `invoice.paid` event
- OrderItem references `subscription_plan` (not `course`)
- Fakturoid invoice created for each payment
- Line item format: "Předplatné - {plan name}"
