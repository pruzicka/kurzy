class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :course, optional: true
  belongs_to :subscription_plan, optional: true

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_amount, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :currency, presence: true
  validate :must_have_course_or_subscription_plan

  def display_name
    title_snapshot.presence || course&.name || subscription_plan&.name
  end

  def total_amount
    unit_amount * quantity
  end

  private

  def must_have_course_or_subscription_plan
    return if course.present? || subscription_plan.present?

    errors.add(:base, "must have either course or subscription_plan")
  end
end

