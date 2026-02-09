class EnrollmentsController < ApplicationController
  before_action :require_user!

  def destroy
    enrollment = current_user.enrollments.find(params[:id])
    enrollment.destroy
    redirect_to user_root_path, notice: "Kurz byl odebrán."
  end
end

