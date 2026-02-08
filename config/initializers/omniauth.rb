Rails.application.config.middleware.use OmniAuth::Builder do
  google_client_id =
    Rails.application.credentials.dig(:google, :client_id) ||
    Rails.application.credentials.dig(:google, :cliend_id) || # tolerate common typo in credentials
    ENV["GOOGLE_CLIENT_ID"]
  google_client_secret = Rails.application.credentials.dig(:google, :client_secret) || ENV["GOOGLE_CLIENT_SECRET"]

  if google_client_id.present? && google_client_secret.present?
    provider(
      :google_oauth2,
      google_client_id,
      google_client_secret,
      scope: "email,profile",
      prompt: "select_account"
    )
  end
end

# OmniAuth 2 expects non-GET by default; this gem adds CSRF protection for the request phase.
OmniAuth.config.allowed_request_methods = %i[post]
