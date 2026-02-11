require "test_helper"

class RefundServiceTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @order = orders(:paid_order)
  end

  test "raises when order is not paid" do
    @order.update_columns(status: "pending")
    assert_raises(RuntimeError) do
      RefundService.new(@order).call
    end
  end

  test "raises when no payment intent" do
    @order.update_columns(stripe_payment_intent_id: nil)
    assert_raises(RuntimeError) do
      RefundService.new(@order).call
    end
  end

  test "creates stripe refund and updates order" do
    refund_called_with = nil
    original_create = Stripe::Refund.method(:create)

    Stripe::Refund.define_singleton_method(:create) do |**params|
      refund_called_with = params
      OpenStruct.new(id: "re_test")
    end

    begin
      RefundService.new(@order, reason: "Test reason").call
    ensure
      Stripe::Refund.define_singleton_method(:create, original_create)
    end

    assert_equal @order.stripe_payment_intent_id, refund_called_with[:payment_intent]
    @order.reload
    assert_not_nil @order.refunded_at
    assert_equal "Test reason", @order.refund_reason
  end

  test "enqueues FakturoidCorrectionJob" do
    original_create = Stripe::Refund.method(:create)
    Stripe::Refund.define_singleton_method(:create) { |**_| OpenStruct.new(id: "re_test") }

    begin
      assert_enqueued_with(job: FakturoidCorrectionJob, args: [@order.id]) do
        RefundService.new(@order).call
      end
    ensure
      Stripe::Refund.define_singleton_method(:create, original_create)
    end
  end
end
