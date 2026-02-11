require "test_helper"

class CourseTagTest < ActiveSupport::TestCase
  test "valid with course and tag" do
    ct = CourseTag.new(course: courses(:two), tag: tags(:ruby))
    assert ct.valid?
  end

  test "rejects duplicate course-tag pair" do
    ct = CourseTag.new(course: courses(:one), tag: tags(:ruby))
    assert_not ct.valid?
  end
end
