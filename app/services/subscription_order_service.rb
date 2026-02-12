class SubscriptionOrderService
  def initialize(subscription, invoice)
    @subscription = subscription
    @invoice = invoice
  end

  def create_order!
    return if Order.exists?(stripe_payment_intent_id: @invoice.payment_intent)

    plan = @subscription.subscription_plan
    user = @subscription.user

    order = Order.create!(
      user: user,
      subscription: @subscription,
      order_type: "subscription",
      status: "paid",
      currency: plan.currency,
      subtotal_amount: @invoice.amount_paid,
      discount_amount: 0,
      total_amount: @invoice.amount_paid,
      stripe_payment_intent_id: @invoice.payment_intent,
      billing_name: user.billing_name.presence || user.name,
      billing_street: user.billing_street,
      billing_city: user.billing_city,
      billing_zip: user.billing_zip,
      billing_country: user.billing_country,
      billing_ico: user.billing_ico,
      billing_dic: user.billing_dic,
      order_items: [
        OrderItem.new(
          subscription_plan: plan,
          quantity: 1,
          unit_amount: @invoice.amount_paid,
          currency: plan.currency,
          title_snapshot: "Předplatné - #{plan.name} (#{@subscription.interval == "year" ? "roční" : "měsíční"})"
        )
      ]
    )

    FakturoidInvoiceJob.perform_later(order.id)
    order
  end
end
