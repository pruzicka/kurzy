class Enrollment < ApplicationRecord
  belongs_to :user
  belongs_to :course
  belongs_to :order

  validates :granted_at, presence: true
end

