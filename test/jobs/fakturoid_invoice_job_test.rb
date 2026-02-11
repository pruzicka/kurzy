require "test_helper"

class FakturoidInvoiceJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test "calls create_invoice! and sends email" do
    order = orders(:paid_order)

    invoice_called = false
    original_new = FakturoidService.method(:new)

    FakturoidService.define_singleton_method(:new) do |*args|
      fake = Object.new
      fake.define_singleton_method(:create_invoice!) { invoice_called = true }
      fake
    end

    begin
      assert_enqueued_emails 1 do
        FakturoidInvoiceJob.perform_now(order.id)
      end
    ensure
      FakturoidService.define_singleton_method(:new, original_new)
    end

    assert invoice_called
  end

  test "skips when invoice already exists" do
    order = orders(:paid_order)
    order.update_columns(fakturoid_invoice_id: 42)

    assert_enqueued_emails 0 do
      FakturoidInvoiceJob.perform_now(order.id)
    end
  end
end
