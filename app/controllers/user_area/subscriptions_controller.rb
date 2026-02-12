module UserArea
  class SubscriptionsController < BaseController
    skip_after_action :verify_authorized

    def index
      @subscriptions = current_user.subscriptions.includes(:subscription_plan).order(created_at: :desc)
    end

    def cancel
      subscription = current_user.subscriptions.find(params[:id])

      Stripe::Subscription.update(
        subscription.stripe_subscription_id,
        cancel_at_period_end: true
      )
      subscription.update!(cancel_at_period_end: true)

      redirect_to user_subscriptions_path, notice: "Předplatné bude zrušeno na konci aktuálního období."
    rescue Stripe::StripeError => e
      Rails.logger.error("Stripe cancel error: #{e.class}: #{e.message}")
      redirect_to user_subscriptions_path, alert: "Nepodařilo se zrušit předplatné."
    end

    def resume
      subscription = current_user.subscriptions.find(params[:id])

      Stripe::Subscription.update(
        subscription.stripe_subscription_id,
        cancel_at_period_end: false
      )
      subscription.update!(cancel_at_period_end: false)

      redirect_to user_subscriptions_path, notice: "Předplatné bylo obnoveno."
    rescue Stripe::StripeError => e
      Rails.logger.error("Stripe resume error: #{e.class}: #{e.message}")
      redirect_to user_subscriptions_path, alert: "Nepodařilo se obnovit předplatné."
    end
  end
end
