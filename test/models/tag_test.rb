require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "valid with name" do
    tag = Tag.new(name: "JavaScript")
    assert tag.valid?
  end

  test "requires name" do
    tag = Tag.new(name: "")
    assert_not tag.valid?
  end

  test "auto-generates slug from name" do
    tag = Tag.new(name: "Ruby on Rails")
    tag.valid?
    assert_equal "ruby-on-rails", tag.slug
  end

  test "name must be unique (case-insensitive)" do
    Tag.create!(name: "Unique")
    tag = Tag.new(name: "unique")
    assert_not tag.valid?
  end

  test "slug must be unique" do
    Tag.create!(name: "Test Tag")
    tag = Tag.new(name: "Test Tag")
    assert_not tag.valid?
  end

  test "has many courses through course_tags" do
    tag = tags(:ruby)
    assert_includes tag.courses, courses(:one)
  end

  test "destroying tag destroys course_tags" do
    tag = tags(:ruby)
    assert_difference "CourseTag.count", -tag.course_tags.count do
      tag.destroy!
    end
  end
end
