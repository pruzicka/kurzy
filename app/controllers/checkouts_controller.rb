class CheckoutsController < ApplicationController
  before_action :require_user!

  def create
    cart = current_user.cart!
    items = cart.cart_items.includes(:course)
    if items.empty?
      redirect_to cart_path, alert: "Košík je prázdný."
      return
    end

    order = build_order!(items)
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

  def build_order!(items)
    currency = items.first.course.currency
    total = items.sum { |item| item.total_amount }
    Order.create!(
      user: current_user,
      status: "pending",
      currency: currency,
      total_amount: total,
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
end
