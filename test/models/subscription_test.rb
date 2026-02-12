require "test_helper"

class SubscriptionTest < ActiveSupport::TestCase
  test "valid subscription" do
    subscription = subscriptions(:active_subscription)
    assert subscription.valid?
  end

  test "rejects invalid status" do
    subscription = subscriptions(:active_subscription)
    subscription.status = "bogus"
    assert_not subscription.valid?
  end

  test "active? returns true for active subscription" do
    assert subscriptions(:active_subscription).active?
  end

  test "active? returns false for canceled subscription" do
    assert_not subscriptions(:canceled_subscription).active?
  end

  test "access_granted? returns true for active" do
    assert subscriptions(:active_subscription).access_granted?
  end

  test "access_granted? returns false for canceled" do
    assert_not subscriptions(:canceled_subscription).access_granted?
  end

  test "active scope" do
    active = Subscription.active
    assert active.all?(&:active?)
  end

  test "active_or_past_due scope includes active" do
    scope = Subscription.active_or_past_due
    assert scope.include?(subscriptions(:active_subscription))
  end
end
