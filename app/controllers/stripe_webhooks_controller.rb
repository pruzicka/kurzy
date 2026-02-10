class StripeWebhooksController < ActionController::Base
  skip_before_action :verify_authenticity_token

  HANDLED_EVENTS = %w[
    checkout.session.completed
    checkout.session.expired
    charge.refunded
  ].freeze

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

    if HANDLED_EVENTS.include?(event.type)
      StripeWebhookJob.perform_later(event.id)
    end

    head :ok
  rescue JSON::ParserError, Stripe::SignatureVerificationError => e
    Rails.logger.warn("Stripe webhook error: #{e.class}: #{e.message}")
    head :bad_request
  end
end
