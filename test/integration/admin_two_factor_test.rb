require "test_helper"

class AdminTwoFactorTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = admins(:one)
  end

  test "login without 2FA works normally" do
    post admin_session_path, params: { admin: { login: @admin.username, password: "password" } }
    assert_redirected_to admin_root_path
    follow_redirect!
    assert_response :success
  end

  test "login with 2FA redirects to OTP challenge" do
    enable_two_factor!(@admin)

    post admin_session_path, params: { admin: { login: @admin.username, password: "password" } }
    assert_redirected_to new_admin_otp_challenge_path
  end

  test "OTP challenge accepts valid TOTP code" do
    enable_two_factor!(@admin)

    post admin_session_path, params: { admin: { login: @admin.username, password: "password" } }
    follow_redirect!
    assert_response :success

    totp = ROTP::TOTP.new(@admin.otp_secret)
    post admin_otp_challenge_path, params: { otp_code: totp.now }
    assert_redirected_to admin_root_path
  end

  test "OTP challenge rejects invalid code" do
    enable_two_factor!(@admin)

    post admin_session_path, params: { admin: { login: @admin.username, password: "password" } }
    follow_redirect!

    post admin_otp_challenge_path, params: { otp_code: "000000" }
    assert_response :unprocessable_entity
  end

  test "OTP challenge accepts recovery code" do
    enable_two_factor!(@admin)
    codes = @admin.generate_otp_backup_codes!

    post admin_session_path, params: { admin: { login: @admin.username, password: "password" } }
    follow_redirect!

    post admin_otp_challenge_path, params: { otp_code: codes.first }
    assert_redirected_to admin_root_path
  end

  test "OTP challenge redirects to login when session expired" do
    get new_admin_otp_challenge_path
    assert_redirected_to new_admin_session_path
  end

  test "OTP session expires after 5 minutes" do
    enable_two_factor!(@admin)

    post admin_session_path, params: { admin: { login: @admin.username, password: "password" } }
    follow_redirect!
    assert_response :success

    travel 6.minutes do
      totp = ROTP::TOTP.new(@admin.otp_secret)
      post admin_otp_challenge_path, params: { otp_code: totp.now }
      assert_redirected_to new_admin_session_path
    end
  end

  private

  def enable_two_factor!(admin)
    admin.update!(otp_secret: ROTP::Base32.random, otp_required_for_login: true)
    admin.generate_otp_backup_codes!
  end
end
