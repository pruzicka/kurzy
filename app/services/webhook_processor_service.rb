class WebhookProcessorService
  def initialize(event)
    @event = event
  end

  def process!
    case @event.type
    when "checkout.session.completed"
      handle_checkout_completed(@event.data.object)
    when "checkout.session.expired"
      handle_checkout_expired(@event.data.object)
    when "charge.refunded"
      handle_charge_refunded(@event.data.object)
    when "customer.subscription.created"
      handle_subscription_created(@event.data.object)
    when "customer.subscription.updated"
      handle_subscription_updated(@event.data.object)
    when "customer.subscription.deleted"
      handle_subscription_deleted(@event.data.object)
    when "invoice.paid"
      handle_invoice_paid(@event.data.object)
    when "invoice.payment_failed"
      handle_invoice_payment_failed(@event.data.object)
    else
      Rails.logger.info("Unhandled Stripe event: #{@event.type}")
    end
  end

  private

  def handle_checkout_completed(session)
    if session.mode == "subscription"
      handle_subscription_checkout_completed(session)
    else
      handle_payment_checkout_completed(session)
    end
  end

  def handle_payment_checkout_completed(session)
    order = Order.find_by(stripe_session_id: session.id)
    return unless order
    return if order.paid? # idempotency

    Order.transaction do
      order.update!(
        status: "paid",
        stripe_payment_intent_id: session.payment_intent
      )

      if session.customer.present? && order.user.stripe_customer_id.blank?
        order.user.update!(stripe_customer_id: session.customer)
      end

      enrollment_service = EnrollmentService.new(order)
      enrollment_service.create_enrollments!
      enrollment_service.record_coupon_redemption!
      enrollment_service.clear_cart!
    end

    OrderMailer.purchase_confirmation(order).deliver_later
    AdminNotificationMailer.new_order(order).deliver_later

    order.enrollments.reload.each do |enrollment|
      EnrollmentMailer.course_granted(enrollment).deliver_later
    end

    FakturoidInvoiceJob.perform_later(order.id)
  end

  def handle_subscription_checkout_completed(session)
    metadata = session.metadata || {}
    user = User.find_by(id: metadata["user_id"])
    plan = SubscriptionPlan.find_by(id: metadata["subscription_plan_id"])
    return unless user && plan

    if session.customer.present? && user.stripe_customer_id.blank?
      user.update!(stripe_customer_id: session.customer)
    end

    # The subscription itself is created via customer.subscription.created event
  end

  def handle_checkout_expired(session)
    order = Order.find_by(stripe_session_id: session.id)
    return unless order
    return unless order.status == "pending" # idempotency

    order.update!(status: "canceled")
  end

  def handle_charge_refunded(charge)
    payment_intent_id = charge.payment_intent
    return unless payment_intent_id.present?

    order = Order.find_by(stripe_payment_intent_id: payment_intent_id)
    return unless order
    return if order.status == "refunded" # idempotency

    Order.transaction do
      order.update!(status: "refunded", refunded_at: order.refunded_at || Time.current)
      EnrollmentService.new(order).revoke_enrollments!
    end

    FakturoidCorrectionJob.perform_later(order.id) if order.fakturoid_invoice?
  end

  def handle_subscription_created(stripe_subscription)
    user = find_user_by_stripe_customer(stripe_subscription.customer)
    return unless user

    plan = find_subscription_plan_from_stripe(stripe_subscription)
    return unless plan

    subscription = Subscription.find_or_initialize_by(
      user: user,
      subscription_plan: plan
    )
    subscription.update!(
      stripe_subscription_id: stripe_subscription.id,
      status: stripe_subscription.status,
      interval: stripe_subscription.items.data.first&.price&.recurring&.interval || "month",
      current_period_start: Time.at(stripe_subscription.current_period_start),
      current_period_end: Time.at(stripe_subscription.current_period_end),
      cancel_at_period_end: stripe_subscription.cancel_at_period_end
    )

    SubscriptionMailer.subscription_activated(subscription).deliver_later if subscription.active?
  end

  def handle_subscription_updated(stripe_subscription)
    subscription = Subscription.find_by(stripe_subscription_id: stripe_subscription.id)
    return unless subscription

    was_active = subscription.active?

    subscription.update!(
      status: stripe_subscription.status,
      current_period_start: Time.at(stripe_subscription.current_period_start),
      current_period_end: Time.at(stripe_subscription.current_period_end),
      cancel_at_period_end: stripe_subscription.cancel_at_period_end
    )

    if !was_active && subscription.active?
      SubscriptionMailer.subscription_activated(subscription).deliver_later
    end
  end

  def handle_subscription_deleted(stripe_subscription)
    subscription = Subscription.find_by(stripe_subscription_id: stripe_subscription.id)
    return unless subscription

    subscription.update!(
      status: "canceled",
      cancel_at_period_end: false
    )

    SubscriptionMailer.subscription_canceled(subscription).deliver_later
  end

  def handle_invoice_paid(invoice)
    return unless invoice.subscription.present?

    subscription = Subscription.find_by(stripe_subscription_id: invoice.subscription)
    return unless subscription

    SubscriptionOrderService.new(subscription, invoice).create_order!
  end

  def handle_invoice_payment_failed(invoice)
    return unless invoice.subscription.present?

    subscription = Subscription.find_by(stripe_subscription_id: invoice.subscription)
    return unless subscription

    SubscriptionMailer.payment_failed(subscription).deliver_later
  end

  def find_user_by_stripe_customer(customer_id)
    User.find_by(stripe_customer_id: customer_id)
  end

  def find_subscription_plan_from_stripe(stripe_subscription)
    price = stripe_subscription.items.data.first&.price
    return unless price

    product_id = price.product
    SubscriptionPlan.find_by(stripe_product_id: product_id)
  end
end
