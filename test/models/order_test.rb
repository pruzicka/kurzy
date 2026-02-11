require "test_helper"

class OrderTest < ActiveSupport::TestCase
  test "paid? returns true when status is paid" do
    assert orders(:paid_order).paid?
  end

  test "paid? returns false when status is pending" do
    assert_not orders(:pending_order).paid?
  end

  test "refundable? returns true for paid order with payment intent" do
    assert orders(:paid_order).refundable?
  end

  test "refundable? returns false for pending order" do
    assert_not orders(:pending_order).refundable?
  end

  test "fakturoid_invoice? returns false without invoice id" do
    assert_not orders(:paid_order).fakturoid_invoice?
  end

  test "fakturoid_invoice? returns true with invoice id" do
    order = orders(:paid_order)
    order.fakturoid_invoice_id = 42
    assert order.fakturoid_invoice?
  end

  test "fakturoid_correction? returns false without correction id" do
    assert_not orders(:paid_order).fakturoid_correction?
  end

  test "billing_info_present? returns true when billing_name is set" do
    order = orders(:paid_order)
    order.billing_name = "Firma s.r.o."
    assert order.billing_info_present?
  end

  test "billing_info_present? returns false when billing_name blank" do
    assert_not orders(:paid_order).billing_info_present?
  end

  test "validates status inclusion" do
    order = orders(:paid_order)
    order.status = "bogus"
    assert_not order.valid?
  end

  test "currency_precision and display_precision" do
    order = orders(:paid_order)
    assert_equal 0, order.display_precision # CZK
    assert_equal 2, order.currency_precision # CZK is not zero-decimal
  end
end
