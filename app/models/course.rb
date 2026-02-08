class Course < ApplicationRecord
  STATUSES = %w[draft public archived].freeze

  validates :name, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :currency, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :slug, uniqueness: true, allow_blank: true

  scope :publicly_visible, -> { where(status: "public") }
end
