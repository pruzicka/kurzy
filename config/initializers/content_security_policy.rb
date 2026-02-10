# Be sure to restart your server when you modify this file.

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data, :blob
    policy.media_src   :self, :blob, :https
    policy.object_src  :none
    policy.script_src  :self, :https
    policy.style_src   :self, :https, :unsafe_inline
    policy.frame_src   "https://checkout.stripe.com", "https://js.stripe.com"
    policy.connect_src :self, "https://api.stripe.com", :https
    policy.form_action :self, "https://checkout.stripe.com"
    policy.frame_ancestors :none
    policy.base_uri    :self
  end

  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w[script-src]

  # Report-only mode — review browser console for violations, then remove this line to enforce.
  config.content_security_policy_report_only = true
end
