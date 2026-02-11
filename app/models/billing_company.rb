class BillingCompany < ApplicationRecord
  validates :name, presence: true
  scope :active, -> { where(active: true) }

  def self.current
    active.first
  end
end
