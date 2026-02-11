class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable,
         :lockable, :timeoutable,
         authentication_keys: [:login]

  validates :username, presence: true, uniqueness: true

  attr_accessor :login

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)&.downcase
    if login.present?
      where("LOWER(username) = :login OR LOWER(email) = :login", login: login).first
    else
      where(conditions.to_h).first
    end
  end

  # --- Two-Factor Authentication (TOTP) ---

  def two_factor_enabled?
    otp_required_for_login? && otp_secret.present?
  end

  def generate_otp_secret!
    update!(otp_secret: ROTP::Base32.random)
  end

  def otp_provisioning_uri
    totp = ROTP::TOTP.new(otp_secret, issuer: "Kurzy Admin")
    totp.provisioning_uri(email)
  end

  def verify_otp(code)
    return false if otp_secret.blank? || code.blank?

    totp = ROTP::TOTP.new(otp_secret)
    timestep = totp.verify(code.to_s.strip, drift_behind: 15, drift_ahead: 15, after: consumed_timestep)
    return false unless timestep

    update!(consumed_timestep: timestep)
    true
  end

  def generate_otp_backup_codes!
    codes = 10.times.map { SecureRandom.hex(4) }
    hashed = codes.map { |c| BCrypt::Password.create(c) }
    update!(otp_backup_codes: hashed)
    codes
  end

  def verify_recovery_code(code)
    return false if code.blank? || otp_backup_codes.blank?

    normalized = code.to_s.strip.downcase
    otp_backup_codes.each_with_index do |hashed, i|
      if BCrypt::Password.new(hashed) == normalized
        remaining = otp_backup_codes.dup
        remaining.delete_at(i)
        update!(otp_backup_codes: remaining)
        return true
      end
    end
    false
  end

  def disable_two_factor!
    update!(
      otp_secret: nil,
      otp_required_for_login: false,
      otp_backup_codes: [],
      consumed_timestep: nil
    )
  end
end
