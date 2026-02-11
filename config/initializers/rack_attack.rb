# frozen_string_literal: true

class Rack::Attack
  ### Safelist health check ###
  safelist("allow-health-check") do |req|
    req.path == "/up"
  end

  ### Global throttle ###
  # 300 requests per minute per IP (covers general abuse)
  throttle("req/ip", limit: 300, period: 1.minute) do |req|
    req.ip unless req.path.start_with?("/assets")
  end

  ### Admin login ###
  # 5 attempts per minute per IP
  throttle("admin-login/ip", limit: 5, period: 1.minute) do |req|
    req.ip if req.path == "/admin/login" && req.post?
  end

  ### OAuth callbacks ###
  # 20 per minute per IP
  throttle("oauth/ip", limit: 20, period: 1.minute) do |req|
    req.ip if req.path.match?(%r{\A/auth/.+/callback\z})
  end

  ### Checkout ###
  # 10 per minute per IP
  throttle("checkout/ip", limit: 10, period: 1.minute) do |req|
    req.ip if req.path == "/checkout" && req.post?
  end

  ### Coupon apply (brute-force protection) ###
  # 5 per minute per IP
  throttle("coupon/ip", limit: 5, period: 1.minute) do |req|
    req.ip if req.path == "/cart/apply_coupon" && req.patch?
  end

  ### Cart operations ###
  # 30 per minute per IP
  throttle("cart/ip", limit: 30, period: 1.minute) do |req|
    req.ip if req.path.start_with?("/cart_items") && req.post?
  end

  ### Stripe webhook ###
  # 100 per minute per IP (already signature-verified, DoS protection)
  throttle("webhook/ip", limit: 100, period: 1.minute) do |req|
    req.ip if req.path == "/webhooks/stripe" && req.post?
  end

  ### User settings update ###
  # 10 per minute per IP
  throttle("settings/ip", limit: 10, period: 1.minute) do |req|
    req.ip if req.path == "/user/settings" && (req.patch? || req.put?)
  end

  ### Account deletion ###
  # 2 per minute per IP
  throttle("account-delete/ip", limit: 2, period: 1.minute) do |req|
    req.ip if req.path == "/user/settings" && req.delete?
  end

  ### Custom throttle response ###
  self.throttled_responder = lambda do |req|
    retry_after = (req.env["rack.attack.match_data"] || {})[:period]
    [
      429,
      { "Content-Type" => "text/plain", "Retry-After" => retry_after.to_s },
      ["Příliš mnoho požadavků. Zkuste to prosím za chvíli.\n"]
    ]
  end
end
