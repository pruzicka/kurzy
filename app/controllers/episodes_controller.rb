class EpisodesController < ApplicationController
  before_action :require_user!
  skip_after_action :verify_authorized

  def show
    @subscription_plan = SubscriptionPlan.publicly_visible.find_by!(slug: params[:subscription_plan_slug])
    @episode = @subscription_plan.episodes.published.find(params[:id])

    unless current_user.subscribed_to?(@subscription_plan)
      redirect_to subscription_plan_path(@subscription_plan.slug), alert: "Pro zobrazení epizody potřebujete aktivní předplatné."
    end
  end
end
