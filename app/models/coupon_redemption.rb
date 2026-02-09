class CouponRedemption < ApplicationRecord
  belongs_to :coupon
  belongs_to :order
  belongs_to :user

  validates :redeemed_at, presence: true
end
