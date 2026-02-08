class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user, :user_signed_in?

  private

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = session[:user_id].present? ? User.find_by(id: session[:user_id]) : nil
  end

  def user_signed_in?
    current_user.present?
  end

  def require_user!
    redirect_to login_path, alert: "Pro pokracovani se prosim prihlaste." unless user_signed_in?
  end

  def after_sign_in_path_for(resource)
    return admin_root_path if resource.is_a?(Admin)
    super
  end
end
