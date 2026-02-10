module UserArea
  class UserSessionsController < BaseController
    def destroy
      user_session = current_user.user_sessions.find(params[:id])
      authorize user_session
      user_session.destroy
      redirect_to edit_user_settings_path, notice: "Relace byla ukončena."
    end

    def destroy_all_other
      skip_authorization
      current_token = session[:session_token]
      current_user.user_sessions.where.not(session_token: current_token).destroy_all
      redirect_to edit_user_settings_path, notice: "Všechny ostatní relace byly ukončeny."
    end
  end
end
