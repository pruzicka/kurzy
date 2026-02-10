class EnrollmentService
  def initialize(order)
    @order = order
  end

  def create_enrollments!
    @order.order_items.each do |item|
      Enrollment.find_or_create_by!(user: @order.user, course: item.course, order: @order) do |enrollment|
        enrollment.granted_at = Time.current
      end
    end
  end

  def revoke_enrollments!
    @order.enrollments.active.find_each do |enrollment|
      enrollment.refund!
      EnrollmentMailer.course_revoked(enrollment).deliver_later
    end
  end

  def record_coupon_redemption!
    return unless @order.coupon.present?
    return if CouponRedemption.exists?(order: @order)

    CouponRedemption.create!(
      order: @order,
      coupon: @order.coupon,
      user: @order.user,
      redeemed_at: Time.current
    )
    @order.coupon.increment!(:redemptions_count)
  end

  def clear_cart!
    @order.user.cart&.cart_items&.destroy_all
    @order.user.cart&.remove_coupon!
  end
end
