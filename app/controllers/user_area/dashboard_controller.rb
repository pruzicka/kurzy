module UserArea
  class DashboardController < BaseController
    def show
      @enrollments = current_user.enrollments.includes(:course).order(created_at: :desc)
    end
  end
end
