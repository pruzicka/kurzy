require "test_helper"

class CourseTest < ActiveSupport::TestCase
  def build_course(attrs = {})
    Course.new({ name: "Test", status: "draft", price: 0, currency: "CZK" }.merge(attrs))
  end

  # ── Validations ──

  test "valid with required attributes" do
    assert build_course.valid?
  end

  test "requires name" do
    assert_not build_course(name: "").valid?
  end

  test "requires status" do
    assert_not build_course(status: "").valid?
  end

  test "rejects invalid status" do
    assert_not build_course(status: "bogus").valid?
  end

  test "requires course_type" do
    assert_not build_course(course_type: "").valid?
  end

  test "rejects invalid course_type" do
    assert_not build_course(course_type: "workshop").valid?
  end

  test "requires currency" do
    assert_not build_course(currency: "").valid?
  end

  test "price must be non-negative integer" do
    assert_not build_course(price: -1).valid?
    assert_not build_course(price: 1.5).valid?
  end

  test "slug must be unique" do
    build_course(slug: "unique-slug").save!
    assert_not build_course(slug: "unique-slug").valid?
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

  # ── Scopes ──

  test "publicly_visible returns only public courses" do
    public_courses = Course.publicly_visible
    assert public_courses.all? { |c| c.status == "public" }
  end

  # ── Associations ──

  test "has many tags through course_tags" do
    course = courses(:one)
    assert_includes course.tags, tags(:ruby)
  end

  test "destroying course destroys course_tags" do
    course = Course.create!(name: "Deletable", status: "draft", price: 0, currency: "CZK")
    tag = tags(:ruby)
    course.tags << tag

    assert_difference "CourseTag.count", -1 do
      course.destroy!
    end
  end

  # ── Instance methods ──

  test "price_in_minor_units returns price * 100 for standard currency" do
    course = build_course(price: 100, currency: "CZK")
    assert_equal 10000, course.price_in_minor_units
  end

  test "price_in_minor_units returns price for zero-decimal currency" do
    course = build_course(price: 1000, currency: "JPY")
    assert_equal 1000, course.price_in_minor_units
  end

  test "currency_precision is 0 for zero-decimal currencies" do
    assert_equal 0, build_course(currency: "JPY").currency_precision
  end

  test "currency_precision is 2 for standard currencies" do
    assert_equal 2, build_course(currency: "USD").currency_precision
  end

  test "display_precision is 0 for CZK" do
    assert_equal 0, build_course(currency: "CZK").display_precision
  end

  test "course_type_label returns correct labels" do
    assert_equal "Online kurz", build_course(course_type: "online_course").course_type_label
    assert_equal "E-book", build_course(course_type: "ebook").course_type_label
    assert_equal "Fyzický trénink", build_course(course_type: "in_person").course_type_label
  end
end
