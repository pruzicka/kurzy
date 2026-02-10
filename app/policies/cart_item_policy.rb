class CartItemPolicy < ApplicationPolicy
  def create?
    user.is_a?(User)
  end

  def update?
    user == record.cart.user
  end

  def destroy?
    user == record.cart.user
  end
end
