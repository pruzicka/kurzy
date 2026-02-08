class UserSessionsController < ApplicationController
  def create
    user = User.from_omniauth(request.env.fetch("omniauth.auth"))
    session[:user_id] = user.id
    redirect_to user_root_path, notice: "Prihlaseno jako #{user.name}."
  rescue StandardError => e
    Rails.logger.warn("User OAuth sign-in failed: #{e.class}: #{e.message}")
    redirect_to root_path, alert: "Prihlaseni se nepovedlo. Zkuste to prosim znovu."
  end

  def destroy
    session.delete(:user_id)
    redirect_to root_path, notice: "Odhlaseno."
  end

  def failure
    redirect_to root_path, alert: "Prihlaseni se nepovedlo."
  end
end

