class Cart < ApplicationRecord
  belongs_to :user
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

  def currency
    cart_items.first&.course&.currency || "CZK"
  end

  def currency_precision
    cart_items.first&.course&.currency_precision || 2
  end
end
