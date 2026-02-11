require "test_helper"

class EnrollmentTest < ActiveSupport::TestCase
  test "valid enrollment" do
    enrollment = enrollments(:active_enrollment)
    assert enrollment.valid?
  end

  test "requires granted_at" do
    enrollment = Enrollment.new(
      user: users(:two),
      course: courses(:two),
      order: orders(:pending_order),
      status: "active",
      granted_at: nil
    )
    assert_not enrollment.valid?
  end

  test "rejects invalid status" do
    enrollment = enrollments(:active_enrollment)
    enrollment.status = "bogus"
    assert_not enrollment.valid?
  end

  test "active? returns true for active enrollment" do
    assert enrollments(:active_enrollment).active?
  end

  test "revoke! changes status to revoked" do
    enrollment = enrollments(:active_enrollment)
    enrollment.revoke!
    assert_equal "revoked", enrollment.reload.status
    assert_not_nil enrollment.revoked_at
  end

  test "refund! changes status to refunded" do
    enrollment = enrollments(:active_enrollment)
    enrollment.refund!
    assert_equal "refunded", enrollment.reload.status
    assert_not_nil enrollment.revoked_at
  end

  test "reinstate! restores active status" do
    enrollment = enrollments(:active_enrollment)
    enrollment.revoke!
    enrollment.reinstate!
    assert_equal "active", enrollment.reload.status
    assert_nil enrollment.revoked_at
  end

  test "active scope returns only active enrollments" do
    enrollments = Enrollment.active
    assert enrollments.all?(&:active?)
  end
end
