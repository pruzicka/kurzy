Stripe.api_key =
  if Rails.env.production?
    Rails.application.credentials.dig(:stripe, :live_secret_key) || ENV["STRIPE_SECRET_KEY"]
  else
    Rails.application.credentials.dig(:stripe, :test_secret_key) || ENV["STRIPE_SECRET_KEY"]
  end
