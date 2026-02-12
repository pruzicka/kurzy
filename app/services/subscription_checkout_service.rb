class SubscriptionCheckoutService
  Result = Struct.new(:success?, :redirect_url, :error, keyword_init: true)

  def initialize(user:, subscription_plan:, interval:, success_url:, cancel_url:)
    @user = user
    @subscription_plan = subscription_plan
    @interval = interval.to_s
    @success_url = success_url
    @cancel_url = cancel_url
  end

  def call
    return Result.new(success?: false, error: "Neplatný interval.") unless %w[month year].include?(@interval)

    if @user.subscribed_to?(@subscription_plan)
      return Result.new(success?: false, error: "Toto předplatné již máte aktivní.")
    end

    sync_stripe_prices!

    price_id = @interval == "month" ? @subscription_plan.stripe_monthly_price_id : @subscription_plan.stripe_annual_price_id

    session = Stripe::Checkout::Session.create(
      mode: "subscription",
      payment_method_types: ["card"],
      customer: @user.find_or_create_stripe_customer!,
      line_items: [{ price: price_id, quantity: 1 }],
      success_url: @success_url + "?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: @cancel_url,
      metadata: {
        subscription_plan_id: @subscription_plan.id,
        user_id: @user.id,
        interval: @interval
      }
    )

    Result.new(success?: true, redirect_url: session.url)
  rescue Stripe::StripeError => e
    Rails.logger.error("Stripe subscription checkout error: #{e.class}: #{e.message}")
    Result.new(success?: false, error: "Platba se nepodařila spustit. Zkuste to prosím znovu.")
  end

  private

  def sync_stripe_prices!
    StripeSubscriptionPlanSyncService.new(@subscription_plan).sync!
  end
end
