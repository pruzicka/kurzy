require "test_helper"

class OrderItemTest < ActiveSupport::TestCase
  test "valid from fixture" do
    assert order_items(:paid_item).valid?
  end

  test "requires positive quantity" do
    item = order_items(:paid_item)
    item.quantity = 0
    assert_not item.valid?
  end

  test "requires currency" do
    item = order_items(:paid_item)
    item.currency = ""
    assert_not item.valid?
  end

  test "display_name uses title_snapshot" do
    item = order_items(:paid_item)
    assert_equal "Ruby on Rails Zaklady", item.display_name
  end

  test "display_name falls back to course name" do
    item = order_items(:paid_item)
    item.title_snapshot = nil
    assert_equal item.course.name, item.display_name
  end

  test "total_amount is unit_amount * quantity" do
    item = order_items(:paid_item)
    assert_equal item.unit_amount * item.quantity, item.total_amount
  end
end
