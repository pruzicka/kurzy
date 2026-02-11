module AdminArea
  class TwoFactorController < BaseController
    skip_after_action :verify_authorized

    def new
      current_admin.generate_otp_secret! unless current_admin.two_factor_enabled?
      @qr_svg = generate_qr_svg
    end

    def create
      if current_admin.verify_otp(params[:otp_code])
        current_admin.update!(otp_required_for_login: true)
        @backup_codes = current_admin.generate_otp_backup_codes!
        render :backup_codes
      else
        flash.now[:alert] = "Neplatný kód. Naskenujte QR znovu a zadejte aktuální kód."
        @qr_svg = generate_qr_svg
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      current_admin.disable_two_factor!
      redirect_to edit_admin_profile_path, notice: "Dvoufaktorové ověření bylo deaktivováno."
    end

    def regenerate_backup_codes
      @backup_codes = current_admin.generate_otp_backup_codes!
      render :backup_codes
    end

    private

    def generate_qr_svg
      uri = current_admin.otp_provisioning_uri
      qr = RQRCode::QRCode.new(uri)
      svg = qr.as_svg(module_size: 4, standalone: true, use_path: true)
      svg.sub(/\A<\?xml[^?]*\?>\s*/, "").sub(/width="\d+"/, 'width="200"').sub(/height="\d+"/, 'height="200"')
    end
  end
end
