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
    else
      Rails.logger.info("Unhandled Stripe event: #{@event.type}")
    end
  end

  private

  def handle_checkout_completed(session)
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
      order.update!(status: "refunded")
      EnrollmentService.new(order).revoke_enrollments!
    end
  end
end
