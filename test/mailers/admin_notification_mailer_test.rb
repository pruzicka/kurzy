require "test_helper"

class AdminNotificationMailerTest < ActionMailer::TestCase
  test "new_order" do
    order = orders(:paid_order)
    mail = AdminNotificationMailer.new_order(order)
    assert_includes mail.subject, order.id.to_s
    assert_includes mail.to, "kurzy@pohybjezivot.cz"
  end
end
