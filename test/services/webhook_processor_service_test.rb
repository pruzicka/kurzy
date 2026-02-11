require "test_helper"

class WebhookProcessorServiceTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "handle_checkout_completed marks order as paid and creates enrollments" do
    order = orders(:pending_order)
    session = OpenStruct.new(
      id: order.stripe_session_id,
      payment_intent: "pi_new_123",
      customer: "cus_test_123"
    )
    event = OpenStruct.new(type: "checkout.session.completed", data: OpenStruct.new(object: session))

    WebhookProcessorService.new(event).process!

    order.reload
    assert_equal "paid", order.status
    assert_equal "pi_new_123", order.stripe_payment_intent_id
    assert order.enrollments.any?
  end

  test "handle_checkout_completed is idempotent" do
    order = orders(:paid_order)
    session = OpenStruct.new(
      id: "cs_already_paid",
      payment_intent: order.stripe_payment_intent_id,
      customer: nil
    )
    order.update_columns(stripe_session_id: "cs_already_paid")
    event = OpenStruct.new(type: "checkout.session.completed", data: OpenStruct.new(object: session))

    assert_no_difference "Enrollment.count" do
      WebhookProcessorService.new(event).process!
    end
  end

  test "handle_checkout_expired cancels pending order" do
    order = orders(:pending_order)
    session = OpenStruct.new(id: order.stripe_session_id)
    event = OpenStruct.new(type: "checkout.session.expired", data: OpenStruct.new(object: session))

    WebhookProcessorService.new(event).process!

    assert_equal "canceled", order.reload.status
  end

  test "handle_charge_refunded refunds order and revokes enrollments" do
    order = orders(:paid_order)
    charge = OpenStruct.new(payment_intent: order.stripe_payment_intent_id)
    event = OpenStruct.new(type: "charge.refunded", data: OpenStruct.new(object: charge))

    WebhookProcessorService.new(event).process!

    order.reload
    assert_equal "refunded", order.status
    assert order.enrollments.reload.none?(&:active?)
  end

  test "handle_charge_refunded is idempotent" do
    order = orders(:paid_order)
    order.update_columns(status: "refunded", refunded_at: 1.day.ago)
    charge = OpenStruct.new(payment_intent: order.stripe_payment_intent_id)
    event = OpenStruct.new(type: "charge.refunded", data: OpenStruct.new(object: charge))

    WebhookProcessorService.new(event).process!
    # no error, stays refunded
    assert_equal "refunded", order.reload.status
  end

  test "unhandled event is silently ignored" do
    event = OpenStruct.new(type: "some.unknown.event", data: OpenStruct.new(object: nil))
    assert_nothing_raised { WebhookProcessorService.new(event).process! }
  end
end
