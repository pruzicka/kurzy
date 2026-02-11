module Admins
  class OtpChallengesController < ApplicationController
    skip_after_action :verify_authorized
    before_action :require_otp_session!

    def new
    end

    def create
      admin = Admin.find_by(id: session[:admin_otp_id])

      unless admin
        clear_otp_session!
        redirect_to new_admin_session_path, alert: "Relace vypršela. Přihlaste se znovu."
        return
      end

      code = params[:otp_code].to_s.strip

      if admin.verify_otp(code) || admin.verify_recovery_code(code)
        clear_otp_session!
        sign_in(:admin, admin)
        redirect_to after_sign_in_path_for(admin), notice: "Přihlášení bylo úspěšné."
      else
        flash.now[:alert] = "Neplatný kód. Zkuste to znovu."
        render :new, status: :unprocessable_entity
      end
    end

    private

    def require_otp_session!
      return if session[:admin_otp_id].present? && otp_session_valid?

      clear_otp_session!
      redirect_to new_admin_session_path, alert: "Relace vypršela. Přihlaste se znovu."
    end

    def otp_session_valid?
      started = session[:admin_otp_at].to_i
      started > 0 && Time.current.to_i - started < 5.minutes.to_i
    end

    def clear_otp_session!
      session.delete(:admin_otp_id)
      session.delete(:admin_otp_at)
    end
  end
end
