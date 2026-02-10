class UserSessionsController < ApplicationController
  skip_after_action :verify_authorized

  def create
    user = User.from_omniauth(request.env.fetch("omniauth.auth"))

    user_session = user.user_sessions.create!(
      session_token: SecureRandom.urlsafe_base64(32),
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      last_active_at: Time.current
    )
    user.enforce_session_limit!

    session[:user_id] = user.id
    session[:session_token] = user_session.session_token

    redirect_to user_root_path, notice: "Přihlášeno jako #{user.name}."
  rescue StandardError => e
    Rails.logger.warn("User OAuth sign-in failed: #{e.class}: #{e.message}")
    redirect_to login_path, alert: "Přihlášení se nepovedlo. Zkuste to prosím znovu."
  end

  def destroy
    if session[:session_token].present?
      ::UserSession.find_by(session_token: session[:session_token])&.destroy
    end
    reset_session
    redirect_to login_path, notice: "Odhlášeno."
  end

  def failure
    redirect_to login_path, alert: "Přihlášení se nepovedlo."
  end
end
