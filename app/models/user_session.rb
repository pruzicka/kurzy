class UserSession < ApplicationRecord
  belongs_to :user

  scope :active, -> { where("last_active_at > ?", 2.weeks.ago) }
  scope :recent, -> { order(last_active_at: :desc) }
end
