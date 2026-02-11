class Order < ApplicationRecord
  belongs_to :user
  belongs_to :coupon, optional: true
  has_many :order_items, dependent: :destroy
  has_many :enrollments, dependent: :destroy

  STATUSES = %w[pending paid canceled refunded].freeze

  validates :status, inclusion: { in: STATUSES }
  validates :currency, presence: true
  validates :subtotal_amount, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :discount_amount, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :total_amount, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def paid?
    status == "paid"
  end

  def fakturoid_invoice?
    fakturoid_invoice_id.present?
  end

  def fakturoid_correction?
    fakturoid_correction_id.present?
  end

  def refundable?
    paid? && stripe_payment_intent_id.present?
  end

  def billing_info_present?
    billing_name.present?
  end

  def currency_precision
    Course::ZERO_DECIMAL_CURRENCIES.include?(currency.to_s.upcase) ? 0 : 2
  end

  def display_precision
    return 0 if currency.to_s.upcase == "CZK"
    currency_precision
  end
end
