module AdminArea
  class DashboardController < BaseController
    skip_after_action :verify_authorized

    def show
      @total_users = User.count
      @total_orders = Order.count
      @paid_orders = Order.where(status: "paid").count
      @revenue_total = Order.where(status: "paid").sum(:total_amount)
      @revenue_30d = Order.where(status: "paid", created_at: 30.days.ago..Time.current).sum(:total_amount)
      @active_enrollments = Enrollment.active.count

      total_segments = Enrollment.active.joins(course: { chapters: :segments }).count("segments.id")
      completed_segments = SegmentCompletion.count
      @completion_rate = if total_segments.positive?
                           ((completed_segments.to_f / total_segments) * 100).round
                         else
                           0
                         end

      @top_courses = Course.joins(:enrollments).group("courses.id").order("COUNT(enrollments.id) DESC").limit(5).count

      @recent_orders = Order.where(status: "paid")
                            .includes(:user, order_items: :course)
                            .order(updated_at: :desc)
                            .limit(10)
    end
  end
end
