require "test_helper"

class FakturoidCorrectionJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test "calls create_correction! and sends email" do
    order = orders(:paid_order)
    order.update_columns(fakturoid_invoice_id: 42)

    correction_called = false
    original_new = FakturoidService.method(:new)

    FakturoidService.define_singleton_method(:new) do |*args|
      fake = Object.new
      fake.define_singleton_method(:create_correction!) { correction_called = true }
      fake
    end

    begin
      assert_enqueued_emails 1 do
        FakturoidCorrectionJob.perform_now(order.id)
      end
    ensure
      FakturoidService.define_singleton_method(:new, original_new)
    end

    assert correction_called
  end

  test "skips when correction already exists" do
    order = orders(:paid_order)
    order.update_columns(fakturoid_invoice_id: 42, fakturoid_correction_id: 99)

    assert_enqueued_emails 0 do
      FakturoidCorrectionJob.perform_now(order.id)
    end
  end

  test "skips when no invoice exists" do
    order = orders(:paid_order)

    assert_enqueued_emails 0 do
      FakturoidCorrectionJob.perform_now(order.id)
    end
  end
end
