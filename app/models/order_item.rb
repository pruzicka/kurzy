class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :course

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_amount, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :currency, presence: true

  def display_name
    title_snapshot.presence || course.name
  end

  def total_amount
    unit_amount * quantity
  end
end

