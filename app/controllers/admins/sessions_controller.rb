module Admins
  class SessionsController < Devise::SessionsController
    def create
      self.resource = warden.authenticate!(auth_options)

      if resource.two_factor_enabled?
        sign_out(resource)
        session[:admin_otp_id] = resource.id
        session[:admin_otp_at] = Time.current.to_i
        redirect_to new_admin_otp_challenge_path
      else
        set_flash_message!(:notice, :signed_in)
        sign_in(resource_name, resource)
        yield resource if block_given?
        respond_with resource, location: after_sign_in_path_for(resource)
      end
    end
  end
end
