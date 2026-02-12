# Subscription System

## Overview

The subscription system provides recurring monthly/annual billing via Stripe Subscriptions. It follows a Netflix model: cancel = lose access at end of billing period. Subscriptions are standalone (not tied to the Course/Chapter/Segment model) and are organized around **SubscriptionPlans** that contain **Episodes**.

## Models

### SubscriptionPlan

**Table:** `subscription_plans`

| Column                  | Type    | Constraints / Default          |
|------------------------|---------|-------------------------------|
| author_id              | integer | NOT NULL, FK → authors         |
| name                   | string  | NOT NULL                       |
| slug                   | string  | NOT NULL, UNIQUE               |
| status                 | string  | default: "draft"               |
| monthly_price          | integer | NOT NULL, default: 0           |
| currency               | string  | default: "CZK"                 |
| annual_discount_percent| integer | default: 0 (0–100)             |
| stripe_product_id      | string  |                                |
| stripe_monthly_price_id| string  |                                |
| stripe_annual_price_id | string  |                                |

**Statuses:** `draft`, `public`, `archived`

**Associations:**
- `belongs_to :author`
- `has_many :episodes` (ordered by position)
- `has_many :subscriptions`
- `has_many :order_items`
- `has_rich_text :description` (Action Text)
- `has_one_attached :cover_image` (Active Storage)

**Slug:** Auto-generated from name if left blank (e.g. "Fitness Premium" → `fitness-premium`).

**Pricing:**
- `monthly_price` is stored in major currency units (e.g. 299 = 299 CZK)
- `annual_price` = `monthly_price * 12 * (100 - annual_discount_percent) / 100`
- Minor unit conversion (for Stripe): `monthly_price_in_minor_units`, `annual_price_in_minor_units`

### Episode

**Table:** `episodes`

| Column              | Type     | Constraints / Default                          |
|--------------------|----------|-----------------------------------------------|
| subscription_plan_id| integer | NOT NULL, FK → subscription_plans              |
| title               | string  | NOT NULL                                       |
| status              | string  | default: "draft"                               |
| position            | integer | NOT NULL, unique with subscription_plan_id     |
| published_at        | datetime|                                                |

**Statuses:** `draft`, `published`

**Associations:**
- `belongs_to :subscription_plan`
- `has_rich_text :content` (Action Text)
- `has_one_attached :cover_image` (Active Storage)
- `has_one_attached :media` (Active Storage — audio/video, max 500 MB)

**Ordering:** Episodes auto-assign position on create. Supports `move_up!` / `move_down!` with swap logic to avoid unique index violations.

### Subscription

**Table:** `subscriptions`

| Column              | Type     | Constraints / Default                          |
|--------------------|----------|-----------------------------------------------|
| user_id            | integer  | NOT NULL, FK → users                           |
| subscription_plan_id| integer | NOT NULL, FK → subscription_plans              |
| stripe_subscription_id| string| UNIQUE                                         |
| status             | string   | default: "incomplete"                          |
| interval           | string   | default: "month"                               |
| current_period_start| datetime|                                                |
| current_period_end | datetime |                                                |
| cancel_at_period_end| boolean | default: false                                 |

Unique index on `[user_id, subscription_plan_id]` — one subscription per user per plan.

**Statuses:** `incomplete`, `active`, `past_due`, `canceled`, `unpaid`

**Access logic:**
- `active?` — status is "active"
- `access_granted?` — status is "active" or "past_due" (grace period while payment retries)

**Scopes:** `active`, `active_or_past_due`

## Checkout Flow

Subscriptions bypass the cart entirely. The flow is:

1. User clicks "Předplatit měsíčně" or "Předplatit ročně" on the subscription plan page
2. `SubscriptionCheckoutsController#create` is called
3. `SubscriptionCheckoutService` syncs Stripe Product + Prices (creates or updates) via `StripeSubscriptionPlanSyncService`
4. Creates a Stripe Checkout Session in `mode: "subscription"`
5. User is redirected to Stripe Checkout
6. On success, Stripe fires webhooks

**Routes:**
- `POST /predplatne-checkout` — initiate checkout (params: `subscription_plan_slug`, `interval`)
- `GET /predplatne-checkout/success` — confirmation page

## Stripe Integration

### Stripe Objects Created

Per SubscriptionPlan:
- 1 **Product** (synced from plan name)
- 2 **Prices** (monthly + annual recurring)

IDs are stored on the SubscriptionPlan record (`stripe_product_id`, `stripe_monthly_price_id`, `stripe_annual_price_id`).

### Webhook Events

The following events are handled (in addition to the existing checkout/refund events):

| Event                           | Handler                         | Action                                                |
|--------------------------------|--------------------------------|-------------------------------------------------------|
| `customer.subscription.created`| `handle_subscription_created`  | Creates/updates Subscription record, sends activation email |
| `customer.subscription.updated`| `handle_subscription_updated`  | Updates status, period dates, cancel_at_period_end     |
| `customer.subscription.deleted`| `handle_subscription_deleted`  | Sets status to "canceled", sends cancellation email    |
| `invoice.paid`                 | `handle_invoice_paid`          | Creates Order + OrderItem for accounting trail         |
| `invoice.payment_failed`       | `handle_invoice_payment_failed`| Sends payment failed email                             |

The `checkout.session.completed` handler now branches on `session.mode`:
- `"payment"` — existing one-time purchase flow
- `"subscription"` — stores Stripe customer ID on user (the subscription itself is created via `customer.subscription.created`)

### Stripe Dashboard Webhook Config

Add these events to your webhook endpoint:

```
customer.subscription.created
customer.subscription.updated
customer.subscription.deleted
invoice.paid
invoice.payment_failed
```

## Order Integration

Each `invoice.paid` event creates an Order record for the accounting/Fakturoid trail:

- `order_type: "subscription"` (vs `"one_time"` for course purchases)
- `belongs_to :subscription`
- OrderItem references `subscription_plan` instead of `course`
- `title_snapshot` format: "Předplatné - Plan Name (měsíční/roční)"

The `FakturoidService` handles subscription items with the line name format: `"Předplatné - {plan_name}"`.

## User Area

### Dashboard (`/user`)

Active subscriptions are displayed below enrolled courses in a "Moje předplatné" section.

### Subscriptions Management (`/user/subscriptions`)

Users can view all their subscriptions with:
- Status badge (active/past_due/canceled)
- Next payment date or end date
- **Cancel** button — sets `cancel_at_period_end: true` via Stripe API. Access continues until period end.
- **Resume** button — reverses cancellation by setting `cancel_at_period_end: false`

## Public Pages

- `/predplatne` — index of all public subscription plans
- `/predplatne/:slug` — plan detail with episode list, pricing, subscribe buttons
- `/predplatne/:slug/epizody/:id` — episode detail (gated: requires active subscription)

Plans are included in the sitemap with priority 0.8.

## Admin Area

**URL:** `/admin/subscription_plans`

Accessible from admin navigation under "Předplatné".

### Subscription Plans
- Full CRUD with cover image upload
- Form fields: name, slug (auto-generated), status, author, monthly price, currency, annual discount %, description, cover image

### Episodes (nested under plan)
- Create/edit/delete with rich text content, cover image, and media upload
- Reorder via move up/down buttons (turbo_stream support)
- Published/draft status toggle
- Published date field

## Email Notifications

`SubscriptionMailer` sends:
- **subscription_activated** — when subscription becomes active
- **subscription_canceled** — when subscription is fully canceled
- **payment_failed** — when an invoice payment fails
