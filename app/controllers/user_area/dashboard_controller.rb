module UserArea
  class DashboardController < BaseController
    skip_after_action :verify_authorized

    def show
      @enrollments = current_user.enrollments.active.includes(:course).order(created_at: :desc)
    end
  end
end
