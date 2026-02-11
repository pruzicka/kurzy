require "test_helper"

class CouponTest < ActiveSupport::TestCase
  # ── Validations ──

  test "valid percent coupon" do
    coupon = Coupon.new(code: "NEW10", discount_type: "percent", value: 10)
    assert coupon.valid?
  end

  test "valid amount coupon" do
    coupon = Coupon.new(code: "FLAT50", discount_type: "amount", value: 50, currency: "CZK")
    assert coupon.valid?
  end

  test "requires code" do
    coupon = Coupon.new(code: "", discount_type: "percent", value: 10)
    assert_not coupon.valid?
  end

  test "normalizes code to uppercase" do
    coupon = Coupon.new(code: " sleva ", discount_type: "percent", value: 10)
    coupon.valid?
    assert_equal "SLEVA", coupon.code
  end

  test "code must be unique" do
    coupon = Coupon.new(code: "SLEVA10", discount_type: "percent", value: 10)
    assert_not coupon.valid?
  end

  test "rejects invalid discount_type" do
    coupon = Coupon.new(code: "X", discount_type: "bogus", value: 10)
    assert_not coupon.valid?
  end

  test "value must be positive integer" do
    coupon = Coupon.new(code: "X", discount_type: "percent", value: 0)
    assert_not coupon.valid?
  end

  test "percent value must be between 1 and 100" do
    coupon = Coupon.new(code: "X", discount_type: "percent", value: 101)
    assert_not coupon.valid?
    assert coupon.errors[:value].any?
  end

  test "amount value can exceed 100" do
    coupon = Coupon.new(code: "X", discount_type: "amount", value: 500, currency: "CZK")
    assert coupon.valid?
  end

  # ── Type predicates ──

  test "percent? and amount?" do
    assert coupons(:percent_coupon).percent?
    assert_not coupons(:percent_coupon).amount?
    assert coupons(:amount_coupon).amount?
    assert_not coupons(:amount_coupon).percent?
  end

  # ── active_now? ──

  test "active_now? returns true for active coupon" do
    assert coupons(:percent_coupon).active_now?
  end

  test "active_now? returns false for inactive coupon" do
    assert_not coupons(:inactive_coupon).active_now?
  end

  test "active_now? respects date range" do
    coupon = coupons(:percent_coupon)
    coupon.starts_at = 1.day.from_now
    assert_not coupon.active_now?

    coupon.starts_at = 1.day.ago
    coupon.ends_at = 1.hour.ago
    assert_not coupon.active_now?
  end

  # ── available_for? ──

  test "available_for? returns false when max redemptions reached" do
    assert_not coupons(:maxed_coupon).available_for?("CZK")
  end

  test "available_for? returns false for currency mismatch on amount coupon" do
    assert_not coupons(:amount_coupon).available_for?("USD")
  end

  test "available_for? ignores currency for percent coupons" do
    assert coupons(:percent_coupon).available_for?("USD")
  end

  # ── discount_for ──

  test "discount_for percent coupon" do
    coupon = coupons(:percent_coupon) # 10%
    assert_equal 1000, coupon.discount_for(10000, "CZK")
  end

  test "discount_for amount coupon with CZK (zero-decimal display but standard Stripe)" do
    coupon = coupons(:amount_coupon) # 100 CZK
    # amount_in_minor_units: 100 * 100 = 10000
    assert_equal 10000, coupon.discount_for(20000, "CZK")
  end

  test "discount_for returns 0 when unavailable" do
    assert_equal 0, coupons(:inactive_coupon).discount_for(10000, "CZK")
  end

  test "discount_for returns 0 when subtotal is zero" do
    assert_equal 0, coupons(:percent_coupon).discount_for(0, "CZK")
  end
end
