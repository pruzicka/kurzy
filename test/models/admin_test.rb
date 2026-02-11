require "test_helper"

class AdminTest < ActiveSupport::TestCase
  test "valid admin from fixture" do
    assert admins(:one).valid?
  end

  test "requires username" do
    admin = Admin.new(username: "", email: "a@b.com", password: "password")
    assert_not admin.valid?
  end

  test "username must be unique" do
    admin = Admin.new(username: admins(:one).username, email: "other@b.com", password: "password")
    assert_not admin.valid?
  end

  test "find_for_database_authentication by username" do
    admin = Admin.find_for_database_authentication(login: "admin1")
    assert_equal admins(:one), admin
  end

  test "find_for_database_authentication by email" do
    admin = Admin.find_for_database_authentication(login: "admin1@example.com")
    assert_equal admins(:one), admin
  end

  test "find_for_database_authentication case-insensitive" do
    admin = Admin.find_for_database_authentication(login: "ADMIN1")
    assert_equal admins(:one), admin
  end
end
