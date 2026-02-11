require "test_helper"

class OrderMailerTest < ActionMailer::TestCase
  test "purchase_confirmation" do
    order = orders(:paid_order)
    mail = OrderMailer.purchase_confirmation(order)
    assert_equal "Potvrzení objednávky ##{order.id}", mail.subject
    assert_includes mail.to, order.user.email
  end

  test "invoice_ready" do
    order = orders(:paid_order)
    mail = OrderMailer.invoice_ready(order)
    assert_equal "Faktura k objednávce ##{order.id}", mail.subject
    assert_includes mail.to, order.user.email
  end

  test "refund_confirmation" do
    order = orders(:paid_order)
    mail = OrderMailer.refund_confirmation(order)
    assert_equal "Vratka k objednávce ##{order.id}", mail.subject
    assert_includes mail.to, order.user.email
  end
end
