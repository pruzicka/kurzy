require "test_helper"

class CourseProgressTest < ActiveSupport::TestCase
  test "valid from fixture" do
    assert course_progresses(:one).valid?
  end

  test "belongs to user, course, and last_segment" do
    cp = course_progresses(:one)
    assert_instance_of User, cp.user
    assert_instance_of Course, cp.course
    assert_instance_of Segment, cp.last_segment
  end
end
