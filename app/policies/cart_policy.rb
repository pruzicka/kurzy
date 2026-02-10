class CartPolicy < ApplicationPolicy
  def show?
    user == record.user
  end

  def apply_coupon?
    user == record.user
  end

  def remove_coupon?
    user == record.user
  end
end
