class StripeWebhookJob < ApplicationJob
  queue_as :default

  def perform(event_id)
    event = Stripe::Event.retrieve(event_id)
    WebhookProcessorService.new(event).process!
  end
end
