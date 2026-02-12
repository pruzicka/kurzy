class SubscriptionCheckoutsController < ApplicationController
  before_action :require_user!
  skip_after_action :verify_authorized

  def create
    plan = SubscriptionPlan.publicly_visible.find_by!(slug: params[:subscription_plan_slug])

    result = SubscriptionCheckoutService.new(
      user: current_user,
      subscription_plan: plan,
      interval: params[:interval] || "month",
      success_url: subscription_checkout_success_url,
      cancel_url: subscription_plan_url(plan.slug)
    ).call

    if result.success?
      redirect_to result.redirect_url, allow_other_host: true
    else
      redirect_to subscription_plan_path(plan.slug), alert: result.error
    end
  end

  def success
  end
end
