require "test_helper"

class BillingCompanyTest < ActiveSupport::TestCase
  test "requires name" do
    bc = BillingCompany.new(name: "")
    assert_not bc.valid?
  end

  test "current returns first active company" do
    assert_equal billing_companies(:active_company), BillingCompany.current
  end

  test "current returns nil when no active company" do
    BillingCompany.update_all(active: false)
    assert_nil BillingCompany.current
  end
end
