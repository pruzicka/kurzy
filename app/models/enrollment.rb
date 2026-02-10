class Enrollment < ApplicationRecord
  belongs_to :user
  belongs_to :course
  belongs_to :order

  STATUSES = %w[active revoked refunded].freeze

  validates :granted_at, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :active, -> { where(status: "active") }

  def active?
    status == "active"
  end

  def revoke!
    update!(status: "revoked", revoked_at: Time.current)
  end

  def refund!
    update!(status: "refunded", revoked_at: Time.current)
  end

  def reinstate!
    update!(status: "active", revoked_at: nil)
  end
end
