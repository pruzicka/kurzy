class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :course

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }

  def unit_amount
    course.price_in_minor_units
  end

  def total_amount
    unit_amount * quantity
  end
end

