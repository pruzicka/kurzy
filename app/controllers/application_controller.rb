class ApplicationController < ActionController::Base
  include Pagy::Backend
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  after_action :verify_authorized, unless: -> { devise_controller? }

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  helper_method :current_user, :user_signed_in?
  before_action :set_active_storage_url_options
  before_action :validate_session

  private

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = session[:user_id].present? ? User.find_by(id: session[:user_id]) : nil
  end

  def user_signed_in?
    current_user.present?
  end

  def require_user!
    redirect_to login_path, alert: "Pro pokračování se prosím přihlaste." unless user_signed_in?
  end

  def require_enrollment!(course)
    return if current_user&.enrollments&.active&.exists?(course: course)

    redirect_to courses_path, alert: "Tento kurz je dostupný pouze po zakoupení."
  end

  MAX_SESSION_AGE = 30.days

  def validate_session
    return unless session[:user_id].present?
    return unless session[:session_token].present?

    user_session = ::UserSession.find_by(session_token: session[:session_token])

    if user_session.nil?
      reset_session
      redirect_to login_path, alert: "Vaše relace byla ukončena."
      return
    end

    if user_session.created_at < MAX_SESSION_AGE.ago
      user_session.destroy
      reset_session
      redirect_to login_path, alert: "Vaše relace vypršela. Přihlaste se prosím znovu."
      return
    end

    if user_session.last_active_at.nil? || user_session.last_active_at < 5.minutes.ago
      user_session.update_columns(
        last_active_at: Time.current,
        ip_address: request.remote_ip,
        user_agent: request.user_agent
      )
    end
  end

  # Needed for Active Storage disk service URLs (dev/test).
  def set_active_storage_url_options
    ActiveStorage::Current.url_options = {
      protocol: request.protocol,
      host: request.host,
      port: request.optional_port
    }
  end

  def after_sign_in_path_for(resource)
    return admin_root_path if resource.is_a?(Admin)
    super
  end

  def user_not_authorized
    redirect_back fallback_location: root_path, alert: "K této akci nemáte oprávnění."
  end
end
