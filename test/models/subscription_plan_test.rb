require "test_helper"

class SubscriptionPlanTest < ActiveSupport::TestCase
  test "valid subscription plan" do
    plan = subscription_plans(:one)
    assert plan.valid?
  end

  test "requires name" do
    plan = SubscriptionPlan.new(slug: "test", author: authors(:one))
    assert_not plan.valid?
    assert_includes plan.errors[:name], "can't be blank"
  end

  test "auto-generates slug from name" do
    plan = SubscriptionPlan.new(name: "Muj Super Plan", author: authors(:one))
    plan.valid?
    assert_equal "muj-super-plan", plan.slug
  end

  test "slug must be unique" do
    existing = subscription_plans(:one)
    plan = SubscriptionPlan.new(name: "Test", slug: existing.slug, author: authors(:one))
    assert_not plan.valid?
    assert_includes plan.errors[:slug], "has already been taken"
  end

  test "rejects invalid status" do
    plan = subscription_plans(:one)
    plan.status = "bogus"
    assert_not plan.valid?
  end

  test "annual_price with discount" do
    plan = subscription_plans(:one)
    # monthly_price: 299, annual_discount_percent: 20
    expected = 299 * 12 * 80 / 100
    assert_equal expected, plan.annual_price
  end

  test "annual_price without discount" do
    plan = subscription_plans(:two)
    # monthly_price: 199, annual_discount_percent: 0
    assert_equal 199 * 12, plan.annual_price
  end

  test "monthly_price_in_minor_units for CZK" do
    plan = subscription_plans(:one)
    assert_equal 299 * 100, plan.monthly_price_in_minor_units
  end

  test "does not overwrite existing slug" do
    plan = SubscriptionPlan.new(name: "Test", slug: "custom-slug", author: authors(:one))
    plan.valid?
    assert_equal "custom-slug", plan.slug
  end

  test "publicly_visible scope" do
    plans = SubscriptionPlan.publicly_visible
    assert plans.all? { |p| p.status == "public" }
  end
end
