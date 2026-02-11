# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = 'https://27fc4d2146dfe8621804f33b6b77c7e0@o4510867161939968.ingest.us.sentry.io/4510867173867520'
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.dsn = ENV['SENTRY_DSN']
  config.traces_sample_rate = 1.0
end
