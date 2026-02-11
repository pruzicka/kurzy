require "test_helper"

class OauthIdentityTest < ActiveSupport::TestCase
  test "valid from fixture" do
    assert oauth_identities(:user_one_google).valid?
  end

  test "requires provider" do
    oi = OauthIdentity.new(user: users(:one), uid: "123", provider: "")
    assert_not oi.valid?
  end

  test "requires uid" do
    oi = OauthIdentity.new(user: users(:one), uid: "", provider: "google_oauth2")
    assert_not oi.valid?
  end

  test "provider+uid must be unique" do
    existing = oauth_identities(:user_one_google)
    oi = OauthIdentity.new(user: users(:two), uid: existing.uid, provider: existing.provider)
    assert_not oi.valid?
  end
end
