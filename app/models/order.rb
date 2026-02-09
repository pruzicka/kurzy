class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :enrollments, dependent: :destroy

  STATUSES = %w[pending paid canceled].freeze

  validates :status, inclusion: { in: STATUSES }
  validates :currency, presence: true

  def paid?
    status == "paid"
  end
end

