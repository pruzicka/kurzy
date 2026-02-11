require "test_helper"

class CartItemTest < ActiveSupport::TestCase
  test "valid from fixture" do
    assert cart_items(:cart_item_one).valid?
  end

  test "requires positive quantity" do
    item = cart_items(:cart_item_one)
    item.quantity = 0
    assert_not item.valid?
  end

  test "unit_amount delegates to course.price_in_minor_units" do
    item = cart_items(:cart_item_one)
    assert_equal item.course.price_in_minor_units, item.unit_amount
  end

  test "total_amount is unit_amount times quantity" do
    item = cart_items(:cart_item_one)
    item.quantity = 3
    assert_equal item.unit_amount * 3, item.total_amount
  end
end
