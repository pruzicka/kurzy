module UserArea
  class SettingsController < BaseController
    def edit
      @user = current_user
    end

    def update
      @user = current_user
      if params[:remove_avatar] == "1"
        @user.avatar.purge if @user.avatar.attached?
      end

      if @user.update(user_params)
        redirect_to edit_user_settings_path, notice: "Nastavení byla uložena."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      current_user.destroy!
      reset_session
      redirect_to root_path, notice: "Účet byl smazán."
    end

    private

    def user_params
      params.require(:user).permit(:first_name, :last_name, :username, :email, :avatar)
    end
  end
end
