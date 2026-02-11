require "test_helper"

class StripeWebhookJobTest < ActiveJob::TestCase
  test "retrieves event and processes it" do
    event = OpenStruct.new(type: "some.event", data: OpenStruct.new(object: nil))
    processed = false

    original_retrieve = Stripe::Event.method(:retrieve)
    original_wps_new = WebhookProcessorService.method(:new)

    Stripe::Event.define_singleton_method(:retrieve) { |_id| event }

    WebhookProcessorService.define_singleton_method(:new) do |*args|
      fake = Object.new
      fake.define_singleton_method(:process!) { processed = true }
      fake
    end

    begin
      StripeWebhookJob.perform_now("evt_test_123")
    ensure
      Stripe::Event.define_singleton_method(:retrieve, original_retrieve)
      WebhookProcessorService.define_singleton_method(:new, original_wps_new)
    end

    assert processed
  end
end
