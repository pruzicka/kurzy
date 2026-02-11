class RefundService
  def initialize(order, reason: nil)
    @order = order
    @reason = reason
  end

  def call
    raise "Order is not paid" unless @order.paid?
    raise "Order has no payment intent" if @order.stripe_payment_intent_id.blank?

    create_stripe_refund!
    @order.update!(refund_reason: @reason, refunded_at: Time.current)

    FakturoidCorrectionJob.perform_later(@order.id)
  end

  private

  def create_stripe_refund!
    Stripe::Refund.create(payment_intent: @order.stripe_payment_intent_id)
  end
end
