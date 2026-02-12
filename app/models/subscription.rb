class Subscription < ApplicationRecord
  STATUSES = %w[incomplete active past_due canceled unpaid].freeze

  belongs_to :user
  belongs_to :subscription_plan
  has_many :orders, dependent: :nullify

  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :stripe_subscription_id, uniqueness: true, allow_blank: true

  scope :active, -> { where(status: "active") }
  scope :active_or_past_due, -> { where(status: %w[active past_due]) }

  def active?
    status == "active"
  end

  def access_granted?
    status.in?(%w[active past_due])
  end

  def canceled?
    status == "canceled"
  end
end
