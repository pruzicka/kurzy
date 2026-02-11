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

  # --- Two-Factor Authentication ---

  test "two_factor_enabled? returns false by default" do
    assert_not admins(:one).two_factor_enabled?
  end

  test "two_factor_enabled? returns true when otp_secret and otp_required are set" do
    admin = admins(:one)
    admin.update!(otp_secret: ROTP::Base32.random, otp_required_for_login: true)
    assert admin.two_factor_enabled?
  end

  test "generate_otp_secret! sets otp_secret" do
    admin = admins(:one)
    assert_nil admin.otp_secret
    admin.generate_otp_secret!
    assert_not_nil admin.reload.otp_secret
  end

  test "otp_provisioning_uri returns otpauth uri" do
    admin = admins(:one)
    admin.update!(otp_secret: ROTP::Base32.random)
    uri = admin.otp_provisioning_uri
    assert uri.start_with?("otpauth://totp/")
    assert_includes uri, "Kurzy"
    assert_includes uri, "Admin"
  end

  test "verify_otp accepts valid code" do
    admin = admins(:one)
    admin.update!(otp_secret: ROTP::Base32.random)
    totp = ROTP::TOTP.new(admin.otp_secret)
    code = totp.now
    assert admin.verify_otp(code)
  end

  test "verify_otp rejects invalid code" do
    admin = admins(:one)
    admin.update!(otp_secret: ROTP::Base32.random)
    assert_not admin.verify_otp("000000")
  end

  test "verify_otp prevents replay" do
    admin = admins(:one)
    admin.update!(otp_secret: ROTP::Base32.random)
    totp = ROTP::TOTP.new(admin.otp_secret)
    code = totp.now
    assert admin.verify_otp(code)
    assert_not admin.verify_otp(code)
  end

  test "verify_otp rejects blank code" do
    admin = admins(:one)
    admin.update!(otp_secret: ROTP::Base32.random)
    assert_not admin.verify_otp("")
    assert_not admin.verify_otp(nil)
  end

  test "generate_otp_backup_codes! returns 10 plaintext codes" do
    admin = admins(:one)
    codes = admin.generate_otp_backup_codes!
    assert_equal 10, codes.length
    assert_equal 10, admin.reload.otp_backup_codes.length
    codes.each { |c| assert_match(/\A[0-9a-f]{8}\z/, c) }
  end

  test "verify_recovery_code consumes valid code" do
    admin = admins(:one)
    codes = admin.generate_otp_backup_codes!
    assert admin.verify_recovery_code(codes.first)
    assert_equal 9, admin.reload.otp_backup_codes.length
    assert_not admin.verify_recovery_code(codes.first)
  end

  test "verify_recovery_code rejects invalid code" do
    admin = admins(:one)
    admin.generate_otp_backup_codes!
    assert_not admin.verify_recovery_code("invalid")
  end

  test "disable_two_factor! clears all 2FA fields" do
    admin = admins(:one)
    admin.update!(otp_secret: ROTP::Base32.random, otp_required_for_login: true, consumed_timestep: 123)
    admin.generate_otp_backup_codes!
    admin.disable_two_factor!
    admin.reload
    assert_nil admin.otp_secret
    assert_not admin.otp_required_for_login?
    assert_empty admin.otp_backup_codes
    assert_nil admin.consumed_timestep
  end
end
