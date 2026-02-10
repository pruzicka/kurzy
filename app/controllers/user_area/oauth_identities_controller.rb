module UserArea
  class OauthIdentitiesController < BaseController
    def destroy
      @identity = current_user.oauth_identities.find(params[:id])
      authorize @identity

      if current_user.oauth_identities.count <= 1
        redirect_to edit_user_settings_path, alert: "Nelze odpojit poslední přihlašovací metodu."
        return
      end

      @identity.destroy
      redirect_to edit_user_settings_path, notice: "Účet byl odpojen."
    end
  end
end
