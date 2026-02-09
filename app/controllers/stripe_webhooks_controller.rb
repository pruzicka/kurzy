class StripeWebhooksController < ActionController::Base
  skip_before_action :verify_authenticity_token
  def create
    payload = request.body.read
    signature = request.env["HTTP_STRIPE_SIGNATURE"]
    secret =
      if Rails.env.production?
        Rails.application.credentials.dig(:stripe, :webhook_secret) || ENV["STRIPE_WEBHOOK_SECRET"]
      else
        Rails.application.credentials.dig(:stripe, :dev_webhook_secret) || ENV["STRIPE_WEBHOOK_SECRET"]
      end

    event = if secret.present?
              Stripe::Webhook.construct_event(payload, signature, secret)
            else
              Stripe::Event.construct_from(JSON.parse(payload, symbolize_names: true))
            end

    case event.type
    when "checkout.session.completed"
      handle_checkout_completed(event.data.object)
    end

    head :ok
  rescue JSON::ParserError, Stripe::SignatureVerificationError => e
    Rails.logger.warn("Stripe webhook error: #{e.class}: #{e.message}")
    head :bad_request
  end

  private

  def handle_checkout_completed(session)
    order = Order.find_by(stripe_session_id: session.id)
    return unless order
    return if order.paid?

    Order.transaction do
      order.update!(
        status: "paid",
        stripe_payment_intent_id: session.payment_intent
      )

      order.order_items.each do |item|
        Enrollment.find_or_create_by!(user: order.user, course: item.course, order: order) do |enrollment|
          enrollment.granted_at = Time.current
        end
      end

      order.user.cart&.cart_items&.destroy_all
    end
  end
end
