require "test_helper"

class AdminTwoFactorSetupTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = admins(:two)
    sign_in @admin
  end

  test "shows QR code on setup page" do
    get new_admin_two_factor_path
    assert_response :success
    assert_select "svg"
  end

  test "activates 2FA with valid code" do
    get new_admin_two_factor_path
    @admin.reload

    totp = ROTP::TOTP.new(@admin.otp_secret)
    post admin_two_factor_path, params: { otp_code: totp.now }
    assert_response :success
    assert_select ".font-mono"
    assert @admin.reload.two_factor_enabled?
  end

  test "rejects activation with invalid code" do
    get new_admin_two_factor_path
    post admin_two_factor_path, params: { otp_code: "000000" }
    assert_response :unprocessable_entity
    assert_not @admin.reload.two_factor_enabled?
  end

  test "disables 2FA" do
    enable_two_factor!(@admin)
    delete admin_two_factor_path
    assert_redirected_to edit_admin_profile_path
    assert_not @admin.reload.two_factor_enabled?
  end

  test "regenerates backup codes" do
    enable_two_factor!(@admin)
    old_codes = @admin.otp_backup_codes.dup

    post regenerate_backup_codes_admin_two_factor_path
    assert_response :success
    assert_select ".font-mono"
    assert_not_equal old_codes, @admin.reload.otp_backup_codes
  end

  test "profile page shows 2FA status" do
    get edit_admin_profile_path
    assert_response :success
    assert_match "Neaktivn", response.body

    enable_two_factor!(@admin)
    get edit_admin_profile_path
    assert_match "Aktivn", response.body
  end

  test "requires authentication for 2FA setup" do
    sign_out @admin
    get new_admin_two_factor_path
    assert_redirected_to new_admin_session_path
  end

  private

  def enable_two_factor!(admin)
    admin.update!(otp_secret: ROTP::Base32.random, otp_required_for_login: true)
    admin.generate_otp_backup_codes!
  end
end
