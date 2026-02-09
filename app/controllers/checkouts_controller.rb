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
    session = Stripe::Checkout::Session.create(
      mode: "payment",
      payment_method_types: ["card"],
      customer_email: current_user.email,
      line_items: build_line_items(order),
      success_url: checkout_success_url + "?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: checkout_cancel_url
    )

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
    line_items = []
    items = order.order_items.to_a
    total_units = items.sum(&:quantity)
    total_amount = items.sum { |item| item.unit_amount * item.quantity }
    max_discount = total_amount - total_units
    discount_remaining = [order.discount_amount, max_discount].min

    discount_per_unit = total_units.positive? ? (discount_remaining / total_units) : 0
    remainder = total_units.positive? ? (discount_remaining % total_units) : 0

    items.each do |item|
      description = item.course.description&.body&.present? ? item.course.description.body.to_plain_text.truncate(120) : nil
      product_name = "#{item.course.course_type_label}: #{item.course.name}"

      extra_units = [remainder, item.quantity].min
      remainder -= extra_units

      if discount_remaining.positive? && extra_units.positive?
        unit_amount = [item.unit_amount - discount_per_unit - 1, 1].max
        line_items << {
          quantity: extra_units,
          price_data: {
            currency: item.currency.downcase,
            unit_amount: unit_amount,
            product_data: { name: product_name, description: description }
          }
        }
      end

      remaining_units = item.quantity - extra_units
      if remaining_units.positive?
        unit_amount = [item.unit_amount - discount_per_unit, 1].max
        line_items << {
          quantity: remaining_units,
          price_data: {
            currency: item.currency.downcase,
            unit_amount: unit_amount,
            product_data: { name: product_name, description: description }
          }
        }
      end
    end

    line_items
  end
end
