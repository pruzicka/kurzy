require "test_helper"

class SegmentCompletionTest < ActiveSupport::TestCase
  test "valid from fixture" do
    assert segment_completions(:one).valid?
  end

  test "belongs to user and segment" do
    sc = segment_completions(:one)
    assert_instance_of User, sc.user
    assert_instance_of Segment, sc.segment
  end
end
