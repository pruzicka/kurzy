require "test_helper"

class CouponServiceTest < ActiveSupport::TestCase
  setup do
    @cart = carts(:user_one_cart)
    @cart.update!(coupon: nil)
    @service = CouponService.new(@cart)
  end

  test "apply sets coupon on cart" do
    result = @service.apply("SLEVA10")
    assert result.success?
    assert_equal coupons(:percent_coupon), @cart.reload.coupon
  end

  test "apply returns error for unknown code" do
    result = @service.apply("NONEXISTENT")
    assert_not result.success?
    assert_match(/nebyl nalezen/, result.error)
  end

  test "apply returns error for inactive coupon" do
    result = @service.apply("EXPIRED")
    assert_not result.success?
    assert_match(/není aktivní/, result.error)
  end

  test "remove clears coupon from cart" do
    @cart.update!(coupon: coupons(:percent_coupon))
    result = @service.remove
    assert result.success?
    assert_nil @cart.reload.coupon
  end
end
