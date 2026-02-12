require "test_helper"

class AuthorTest < ActiveSupport::TestCase
  test "valid author" do
    author = authors(:one)
    assert author.valid?
  end

  test "requires first_name" do
    author = Author.new(last_name: "Novak", slug: "test")
    assert_not author.valid?
    assert_includes author.errors[:first_name], "can't be blank"
  end

  test "requires last_name" do
    author = Author.new(first_name: "Jan", slug: "test")
    assert_not author.valid?
    assert_includes author.errors[:last_name], "can't be blank"
  end

  test "auto-generates slug from name" do
    author = Author.new(first_name: "Jan", last_name: "Novak")
    author.valid?
    assert_equal "jan-novak", author.slug
  end

  test "slug must be unique" do
    existing = authors(:one)
    author = Author.new(first_name: "Test", last_name: "Test", slug: existing.slug)
    assert_not author.valid?
    assert_includes author.errors[:slug], "has already been taken"
  end

  test "name returns full name" do
    author = authors(:one)
    assert_equal "Jan Novak", author.name
  end

  test "does not overwrite existing slug" do
    author = Author.new(first_name: "Jan", last_name: "Novak", slug: "custom-slug")
    author.valid?
    assert_equal "custom-slug", author.slug
  end
end
