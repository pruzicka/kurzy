class Coupon < ApplicationRecord
  has_many :coupon_redemptions, dependent: :destroy
  has_many :orders, dependent: :nullify

  DISCOUNT_TYPES = %w[percent amount].freeze

  before_validation :normalize_code

  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :discount_type, inclusion: { in: DISCOUNT_TYPES }
  validates :value, numericality: { only_integer: true, greater_than: 0 }
  validates :max_redemptions, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validate :percent_value_within_range

  def percent?
    discount_type == "percent"
  end

  def amount?
    discount_type == "amount"
  end

  def active_now?(time = Time.current)
    return false unless active?
    return false if starts_at && time < starts_at
    return false if ends_at && time > ends_at

    true
  end

  def available_for?(currency, time: Time.current)
    return false unless active_now?(time)
    return false if max_redemptions.present? && redemptions_count >= max_redemptions
    return false if amount? && currency.present? && self.currency.present? && currency != self.currency

    true
  end

  def discount_for(subtotal_amount, currency)
    return 0 unless available_for?(currency)
    return 0 if subtotal_amount.to_i <= 0

    if percent?
      ((subtotal_amount.to_i * value) / 100.0).round
    else
      amount_in_minor_units(currency)
    end
  end

  def amount_in_minor_units(currency)
    return value.to_i if currency.to_s.blank?
    if Course::ZERO_DECIMAL_CURRENCIES.include?(currency.to_s.upcase)
      value.to_i
    else
      value.to_i * 100
    end
  end

  private

  def normalize_code
    self.code = code.to_s.strip.upcase
  end

  def percent_value_within_range
    return unless percent?
    return if value.to_i.between?(1, 100)

    errors.add(:value, "u procent musi byt mezi 1 a 100")
  end
end
