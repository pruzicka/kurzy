require "test_helper"

class EnrollmentMailerTest < ActionMailer::TestCase
  test "course_granted" do
    enrollment = enrollments(:active_enrollment)
    mail = EnrollmentMailer.course_granted(enrollment)
    assert_includes mail.subject, enrollment.course.name
    assert_includes mail.to, enrollment.user.email
  end

  test "course_revoked" do
    enrollment = enrollments(:active_enrollment)
    mail = EnrollmentMailer.course_revoked(enrollment)
    assert_includes mail.subject, enrollment.course.name
    assert_includes mail.to, enrollment.user.email
  end
end
