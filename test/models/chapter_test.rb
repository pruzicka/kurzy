require "test_helper"

class ChapterTest < ActiveSupport::TestCase
  setup do
    @course = Course.create!(name: "Test Course", status: "draft", price: 0, currency: "CZK")
  end

  test "valid with title" do
    chapter = @course.chapters.build(title: "Intro")
    assert chapter.valid?
  end

  test "requires title" do
    chapter = @course.chapters.build(title: "")
    assert_not chapter.valid?
  end

  test "auto-assigns position on create" do
    ch1 = @course.chapters.create!(title: "First")
    ch2 = @course.chapters.create!(title: "Second")
    assert_equal 1, ch1.position
    assert_equal 2, ch2.position
  end

  test "move_down! swaps positions with next chapter" do
    ch1 = @course.chapters.create!(title: "First")
    ch2 = @course.chapters.create!(title: "Second")

    ch1.move_down!
    assert_equal 2, ch1.reload.position
    assert_equal 1, ch2.reload.position
  end

  test "move_up! swaps positions with previous chapter" do
    ch1 = @course.chapters.create!(title: "First")
    ch2 = @course.chapters.create!(title: "Second")

    ch2.move_up!
    assert_equal 2, ch1.reload.position
    assert_equal 1, ch2.reload.position
  end

  test "move_up! does nothing for first chapter" do
    ch1 = @course.chapters.create!(title: "First")
    ch1.move_up!
    assert_equal 1, ch1.reload.position
  end

  test "move_down! does nothing for last chapter" do
    ch1 = @course.chapters.create!(title: "First")
    ch1.move_down!
    assert_equal 1, ch1.reload.position
  end
end
