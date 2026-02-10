class CheckoutService
  Result = Struct.new(:success?, :redirect_url, :error, keyword_init: true)

  def initialize(user:, cart:, success_url:, cancel_url:)
    @user = user
    @cart = cart
    @success_url = success_url
    @cancel_url = cancel_url
  end

  def call
    items = @cart.cart_items.includes(:course)
    return Result.new(success?: false, error: "Košík je prázdný.") if items.empty?

    if @cart.coupon.present? && !@cart.coupon.available_for?(@cart.currency)
      @cart.remove_coupon!
    end

    order = build_order(items)
    stripe_coupon = build_stripe_coupon(order)

    session_params = {
      mode: "payment",
      payment_method_types: ["card"],
      customer: @user.find_or_create_stripe_customer!,
      line_items: build_line_items(order),
      success_url: @success_url + "?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: @cancel_url
    }
    session_params[:discounts] = [{ coupon: stripe_coupon.id }] if stripe_coupon.present?

    session = Stripe::Checkout::Session.create(session_params)
    order.update!(stripe_session_id: session.id)

    Result.new(success?: true, redirect_url: session.url)
  rescue Stripe::StripeError => e
    Rails.logger.error("Stripe checkout error: #{e.class}: #{e.message}")
    Result.new(success?: false, error: "Platba se nepodařila spustit. Zkuste to prosím znovu.")
  end

  private

  def build_order(items)
    currency = items.first.course.currency
    subtotal = items.sum(&:total_amount)
    discount = @cart.discount_amount
    total = [subtotal - discount, 0].max

    Order.create!(
      user: @user,
      status: "pending",
      currency: currency,
      subtotal_amount: subtotal,
      discount_amount: discount,
      total_amount: total,
      coupon: @cart.coupon,
      order_items: items.map do |item|
        OrderItem.new(
          course: item.course,
          quantity: item.quantity,
          unit_amount: item.unit_amount,
          currency: item.course.currency
        )
      end
    )
  end

  def build_line_items(order)
    order.order_items.map do |item|
      {
        quantity: item.quantity,
        price_data: {
          currency: item.currency.downcase,
          unit_amount: item.unit_amount,
          product_data: {
            name: "#{item.course.course_type_label}: #{item.course.name}",
            description: item.course.description&.body&.present? ? item.course.description.body.to_plain_text.truncate(120) : nil
          }
        }
      }
    end
  end

  def build_stripe_coupon(order)
    return nil if order.coupon.blank?
    return nil if order.discount_amount.to_i <= 0

    attrs = {
      duration: "once",
      name: "Sleva #{order.coupon.code}",
      metadata: { order_id: order.id, coupon_code: order.coupon.code }
    }

    if order.coupon.percent?
      attrs[:percent_off] = order.coupon.value
    else
      attrs[:amount_off] = order.discount_amount
      attrs[:currency] = order.currency.downcase
    end

    Stripe::Coupon.create(attrs)
  end
end
