require "test_helper"

class SegmentTest < ActiveSupport::TestCase
  def build_segment
    course = Course.create!(name: "Test", status: "draft", price: 0, currency: "CZK")
    chapter = course.chapters.create!(title: "Kapitola")
    chapter.segments.build(title: "Segment")
  end

  test "cover_image must be an image" do
    segment = build_segment
    segment.cover_image.attach(io: StringIO.new("hello"), filename: "note.txt", content_type: "text/plain")

    assert_not segment.valid?
    assert_includes segment.errors[:cover_image].join, "pouze obrazek"
  end

  test "cover_image must be under size limit" do
    segment = build_segment
    too_big = StringIO.new("a" * (10.megabytes + 1))
    segment.cover_image.attach(io: too_big, filename: "cover.jpg", content_type: "image/jpeg")

    assert_not segment.valid?
    assert_includes segment.errors[:cover_image].join, "10 MB"
  end

  test "attachments allow pdf and images only" do
    segment = build_segment
    segment.attachments.attach(io: StringIO.new("x"), filename: "evil.exe", content_type: "application/octet-stream")

    assert_not segment.valid?
    assert_includes segment.errors[:attachments].join, "pouze PDF nebo obrazek"
  end
end
