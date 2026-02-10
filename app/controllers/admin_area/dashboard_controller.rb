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

      # Coupon usage: { coupon_id => { coupon:, total:, courses: { course_name => count } } }
      @coupon_usage = {}
      CouponRedemption
        .joins(:coupon, order: { order_items: :course })
        .where(orders: { status: "paid" })
        .select("coupons.id as coupon_id, coupons.code, coupons.discount_type, coupons.value, courses.name as course_name, COUNT(DISTINCT coupon_redemptions.id) as redemption_count")
        .group("coupons.id, coupons.code, coupons.discount_type, coupons.value, courses.name")
        .each do |row|
          entry = @coupon_usage[row.coupon_id] ||= { code: row.code, discount_type: row.discount_type, value: row.value, total: 0, courses: {} }
          entry[:courses][row.course_name] = row.redemption_count
        end
      @coupon_usage.each_value { |e| e[:total] = e[:courses].values.sum }
      @coupon_usage = @coupon_usage.values.sort_by { |e| -e[:total] }
    end
  end
end
