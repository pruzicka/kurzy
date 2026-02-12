class SubscriptionPlansController < ApplicationController
  skip_after_action :verify_authorized

  def index
    @subscription_plans = SubscriptionPlan.publicly_visible.includes(:author).order(created_at: :desc)
  end

  def show
    @subscription_plan = SubscriptionPlan.publicly_visible.includes(episodes: { cover_image_attachment: :blob }).find_by!(slug: params[:slug])
    @episodes = @subscription_plan.episodes.published.ordered
    @subscribed = user_signed_in? && current_user.subscriptions.active_or_past_due.exists?(subscription_plan: @subscription_plan)
  end
end
