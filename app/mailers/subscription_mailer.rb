class SubscriptionMailer < ApplicationMailer
  def subscription_activated(subscription)
    @subscription = subscription
    @user = subscription.user
    @plan = subscription.subscription_plan

    mail(
      to: email_address_with_name(@user.email, @user.name),
      subject: "Předplatné aktivováno: #{@plan.name}"
    )
  end

  def subscription_canceled(subscription)
    @subscription = subscription
    @user = subscription.user
    @plan = subscription.subscription_plan

    mail(
      to: email_address_with_name(@user.email, @user.name),
      subject: "Předplatné zrušeno: #{@plan.name}"
    )
  end

  def payment_failed(subscription)
    @subscription = subscription
    @user = subscription.user
    @plan = subscription.subscription_plan

    mail(
      to: email_address_with_name(@user.email, @user.name),
      subject: "Platba za předplatné selhala: #{@plan.name}"
    )
  end
end
