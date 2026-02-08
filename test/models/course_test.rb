require "test_helper"

class CourseTest < ActiveSupport::TestCase
  def build_course
    Course.new(name: "Test", status: "draft", price: 0, currency: "CZK")
  end

  test "cover_image must be an image" do
    course = build_course
    course.cover_image.attach(io: StringIO.new("hello"), filename: "note.txt", content_type: "text/plain")

    assert_not course.valid?
    assert_includes course.errors[:cover_image].join, "pouze obrazek"
  end

  test "cover_image must be under size limit" do
    course = build_course
    too_big = StringIO.new("a" * (10.megabytes + 1))
    course.cover_image.attach(io: too_big, filename: "cover.jpg", content_type: "image/jpeg")

    assert_not course.valid?
    assert_includes course.errors[:cover_image].join, "10 MB"
  end
end
