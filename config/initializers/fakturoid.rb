if Rails.application.credentials.dig(:fakturoid, :client_id).present?
  Fakturoid.configure do |config|
    config.email = Rails.application.credentials.dig(:fakturoid, :email)
    config.account = Rails.application.credentials.dig(:fakturoid, :slug)
    config.user_agent = "Kurzy (#{config.email})"
    config.client_id = Rails.application.credentials.dig(:fakturoid, :client_id)
    config.client_secret = Rails.application.credentials.dig(:fakturoid, :client_secret)
    config.oauth_flow = "client_credentials"
  end
end
