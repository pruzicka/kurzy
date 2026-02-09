class Cart < ApplicationRecord
  belongs_to :user
  belongs_to :coupon, optional: true
  has_many :cart_items, dependent: :destroy

  def add_course!(course, quantity = 1)
    if cart_items.exists? && course.currency != currency
      raise ArgumentError, "Different currency"
    end

    item = cart_items.find_or_initialize_by(course: course)
    if item.new_record?
      item.quantity = quantity.to_i
    else
      item.quantity += quantity.to_i
    end
    item.quantity = 1 if item.quantity < 1
    item.save!
  end

  def remove_course!(course)
    cart_items.where(course: course).destroy_all
  end

  def total_amount
    cart_items.includes(:course).sum { |item| item.total_amount }
  end

  def subtotal_amount
    total_amount
  end

  def discount_amount
    return 0 unless coupon.present?

    discount = coupon.discount_for(subtotal_amount, currency)
    [discount, subtotal_amount, max_discount_amount].min
  end

  def total_after_discount
    [subtotal_amount - discount_amount, 0].max
  end

  def max_discount_amount
    cart_items.includes(:course).sum do |item|
      min_total = item.quantity
      [item.total_amount - min_total, 0].max
    end
  end

  def apply_coupon!(code)
    coupon = Coupon.find_by(code: code.to_s.strip.upcase)
    raise ArgumentError, "Kupon nenalezen" unless coupon
    raise ArgumentError, "Kupon neni aktivni" unless coupon.available_for?(currency)

    update!(coupon: coupon)
  end

  def remove_coupon!
    update!(coupon: nil)
  end

  def currency
    cart_items.first&.course&.currency || "CZK"
  end

  def currency_precision
    cart_items.first&.course&.currency_precision || 2
  end
end
