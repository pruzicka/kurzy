class UserSessionsController < ApplicationController
  def create
    user = User.from_omniauth(request.env.fetch("omniauth.auth"))
    session[:user_id] = user.id
    redirect_to user_root_path, notice: "Přihlášeno jako #{user.name}."
  rescue StandardError => e
    Rails.logger.warn("User OAuth sign-in failed: #{e.class}: #{e.message}")
    redirect_to login_path, alert: "Přihlášení se nepovedlo. Zkuste to prosím znovu."
  end

  def destroy
    session.delete(:user_id)
    redirect_to login_path, notice: "Odhlášeno."
  end

  def failure
    redirect_to login_path, alert: "Přihlášení se nepovedlo."
  end
end
