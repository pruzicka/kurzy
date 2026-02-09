class CheckoutsController < ApplicationController
  before_action :require_user!

  def create
    cart = current_user.cart!
    items = cart.cart_items.includes(:course)
    if items.empty?
      redirect_to cart_path, alert: "Košík je prázdný."
      return
    end
    if cart.coupon.present? && !cart.coupon.available_for?(cart.currency)
      cart.remove_coupon!
    end

    order = build_order!(cart, items)
    stripe_coupon = build_stripe_coupon(order)
    session_params = {
      mode: "payment",
      payment_method_types: ["card"],
      customer_email: current_user.email,
      line_items: build_line_items(order),
      success_url: checkout_success_url + "?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: checkout_cancel_url
    }
    session_params[:discounts] = [{ coupon: stripe_coupon.id }] if stripe_coupon.present?
    session = Stripe::Checkout::Session.create(session_params)

    order.update!(stripe_session_id: session.id)
    redirect_to session.url, allow_other_host: true
  rescue Stripe::StripeError => e
    Rails.logger.error("Stripe checkout error: #{e.class}: #{e.message}")
    redirect_to cart_path, alert: "Platba se nepodařila spustit. Zkuste to prosím znovu."
  end

  def success
    # Stripe will call webhooks; this is just a friendly landing page.
  end

  def cancel
  end

  private

  def build_order!(cart, items)
    currency = items.first.course.currency
    subtotal = items.sum { |item| item.total_amount }
    discount = cart.discount_amount
    total = [subtotal - discount, 0].max
    Order.create!(
      user: current_user,
      status: "pending",
      currency: currency,
      subtotal_amount: subtotal,
      discount_amount: discount,
      total_amount: total,
      coupon: cart.coupon,
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
      metadata: {
        order_id: order.id,
        coupon_code: order.coupon.code
      }
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
