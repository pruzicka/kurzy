require "test_helper"

class CartTest < ActiveSupport::TestCase
  setup do
    @cart = carts(:user_one_cart)
    @course = courses(:one)
  end

  test "add_course! creates a cart item" do
    @cart.cart_items.destroy_all
    assert_difference "CartItem.count", 1 do
      @cart.add_course!(@course)
    end
  end

  test "add_course! increments quantity for existing item" do
    item = @cart.cart_items.find_by(course: @course)
    original_qty = item.quantity
    @cart.add_course!(@course)
    assert_equal original_qty + 1, item.reload.quantity
  end

  test "add_course! raises on currency mismatch" do
    usd_course = Course.create!(name: "USD Course", status: "draft", price: 10, currency: "USD")
    assert_raises(ArgumentError) { @cart.add_course!(usd_course) }
  end

  test "remove_course! removes the item" do
    assert_difference "CartItem.count", -1 do
      @cart.remove_course!(@course)
    end
  end

  test "total_amount sums all items" do
    assert_equal @course.price_in_minor_units, @cart.total_amount
  end

  test "discount_amount is 0 without coupon" do
    assert_equal 0, @cart.discount_amount
  end

  test "discount_amount calculates with coupon" do
    coupon = coupons(:percent_coupon) # 10%
    @cart.update!(coupon: coupon)
    expected = (@cart.subtotal_amount * 10 / 100.0).round
    assert_equal expected, @cart.discount_amount
  end

  test "total_after_discount subtracts discount" do
    coupon = coupons(:percent_coupon)
    @cart.update!(coupon: coupon)
    assert_equal @cart.subtotal_amount - @cart.discount_amount, @cart.total_after_discount
  end

  test "total_after_discount never goes below 0" do
    # 100% coupon would result in 0
    coupon = Coupon.create!(code: "FREE100", discount_type: "percent", value: 100, active: true)
    @cart.update!(coupon: coupon)
    assert @cart.total_after_discount >= 0
  end

  test "apply_coupon! sets coupon" do
    @cart.update!(coupon: nil)
    @cart.apply_coupon!("SLEVA10")
    assert_equal coupons(:percent_coupon), @cart.reload.coupon
  end

  test "apply_coupon! raises for unknown code" do
    assert_raises(ArgumentError) { @cart.apply_coupon!("NONEXISTENT") }
  end

  test "apply_coupon! raises for inactive coupon" do
    assert_raises(ArgumentError) { @cart.apply_coupon!("EXPIRED") }
  end

  test "remove_coupon! clears coupon" do
    @cart.update!(coupon: coupons(:percent_coupon))
    @cart.remove_coupon!
    assert_nil @cart.reload.coupon
  end

  test "currency returns first item currency" do
    assert_equal "CZK", @cart.currency
  end
end
