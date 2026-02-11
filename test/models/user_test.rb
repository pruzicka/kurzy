require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user from fixture" do
    assert users(:one).valid?
  end

  test "requires email" do
    user = User.new(email: "")
    assert_not user.valid?
    assert user.errors[:email].any?
  end

  test "email must be unique" do
    user = User.new(email: users(:one).email)
    assert_not user.valid?
  end

  test "username must be unique when present" do
    users(:one).update!(username: "taken")
    user = User.new(email: "new@example.com", username: "taken")
    assert_not user.valid?
  end

  test "name returns full name" do
    user = users(:one)
    assert_equal "Jana Novakova", user.name
  end

  test "name returns email when no name" do
    user = User.new(email: "anon@example.com")
    assert_equal "anon@example.com", user.name
  end

  test "cart! creates cart if missing" do
    user = users(:two)
    user.cart&.destroy
    assert_nil user.reload.cart
    cart = user.cart!
    assert_instance_of Cart, cart
    assert cart.persisted?
  end

  test "billing_info_present? requires all four fields" do
    user = users(:one)
    assert_not user.billing_info_present?

    user.assign_attributes(billing_name: "X", billing_street: "Y", billing_city: "Z", billing_zip: "123")
    assert user.billing_info_present?
  end

  test "billing_address_required_with_company_details" do
    user = users(:one)
    user.billing_ico = "12345678"
    assert_not user.valid?
    assert user.errors[:billing_name].any?
    assert user.errors[:billing_street].any?
  end

  test "enforce_session_limit! removes excess sessions" do
    user = users(:one)
    # fixtures have 2 sessions; add a third
    user.user_sessions.create!(session_token: "token_extra", last_active_at: Time.current)
    assert_equal 3, user.user_sessions.count

    user.enforce_session_limit!
    assert_equal 2, user.user_sessions.count
  end

  test "from_omniauth creates new user" do
    auth = {
      "provider" => "google_oauth2",
      "uid" => "999999",
      "info" => { "email" => "brand_new@example.com", "first_name" => "New", "last_name" => "User" }
    }

    user = User.from_omniauth(auth)
    assert user.persisted?
    assert_equal "brand_new@example.com", user.email
    assert_equal 1, user.oauth_identities.count
  end

  test "from_omniauth links existing user by email" do
    auth = {
      "provider" => "google_oauth2",
      "uid" => "newuid123",
      "info" => { "email" => users(:one).email, "first_name" => "Jana" }
    }

    assert_no_difference "User.count" do
      user = User.from_omniauth(auth)
      assert_equal users(:one).id, user.id
    end
  end

  test "from_omniauth finds existing user by identity" do
    auth = {
      "provider" => "google_oauth2",
      "uid" => oauth_identities(:user_one_google).uid,
      "info" => { "email" => users(:one).email, "first_name" => "Jana" }
    }

    assert_no_difference "User.count" do
      user = User.from_omniauth(auth)
      assert_equal users(:one).id, user.id
    end
  end

  test "from_omniauth raises when no email" do
    auth = { "provider" => "google_oauth2", "uid" => "x", "info" => {} }
    assert_raises(ArgumentError) { User.from_omniauth(auth) }
  end
end
