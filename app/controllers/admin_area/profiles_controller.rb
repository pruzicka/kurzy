module AdminArea
  class ProfilesController < BaseController
    skip_after_action :verify_authorized

    def edit
      @admin = current_admin
    end

    def update
      @admin = current_admin
      attrs = admin_params
      if attrs[:password].blank?
        attrs.delete(:password)
        attrs.delete(:password_confirmation)
      end

      if @admin.update(attrs)
        redirect_to edit_admin_profile_path, notice: "Profil uložen."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def admin_params
      params.require(:admin).permit(:first_name, :last_name, :email, :username, :password, :password_confirmation)
    end
  end
end
