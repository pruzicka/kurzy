require "test_helper"

class EnrollmentServiceTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @order = orders(:paid_order)
    @service = EnrollmentService.new(@order)
  end

  test "create_enrollments! creates enrollment for each order item" do
    # Remove existing enrollment to test creation
    Enrollment.where(user: @order.user, order: @order).destroy_all

    assert_difference "Enrollment.count", @order.order_items.count do
      @service.create_enrollments!
    end

    enrollment = Enrollment.find_by(user: @order.user, course: @order.order_items.first.course)
    assert enrollment.present?
    assert_equal "active", enrollment.status
  end

  test "create_enrollments! is idempotent" do
    Enrollment.where(user: @order.user, order: @order).destroy_all
    @service.create_enrollments!

    assert_no_difference "Enrollment.count" do
      @service.create_enrollments!
    end
  end

  test "revoke_enrollments! refunds active enrollments and sends emails" do
    enrollment = enrollments(:active_enrollment)
    assert_equal @order, enrollment.order

    assert_enqueued_emails 1 do
      @service.revoke_enrollments!
    end

    assert_equal "refunded", enrollment.reload.status
  end

  test "record_coupon_redemption! creates redemption when coupon present" do
    coupon = coupons(:percent_coupon)
    @order.update!(coupon: coupon)

    assert_difference "CouponRedemption.count", 1 do
      @service.record_coupon_redemption!
    end
    assert_equal 1, coupon.reload.redemptions_count
  end

  test "record_coupon_redemption! does nothing without coupon" do
    @order.update!(coupon: nil)

    assert_no_difference "CouponRedemption.count" do
      @service.record_coupon_redemption!
    end
  end

  test "record_coupon_redemption! is idempotent" do
    coupon = coupons(:percent_coupon)
    @order.update!(coupon: coupon)
    @service.record_coupon_redemption!

    assert_no_difference "CouponRedemption.count" do
      @service.record_coupon_redemption!
    end
  end

  test "clear_cart! destroys cart items and removes coupon" do
    user = @order.user
    cart = user.cart || user.create_cart!
    cart.update!(coupon: coupons(:percent_coupon))
    cart.cart_items.find_or_create_by!(course: courses(:one), quantity: 1)

    @service.clear_cart!

    assert_equal 0, cart.reload.cart_items.count
    assert_nil cart.coupon
  end
end
