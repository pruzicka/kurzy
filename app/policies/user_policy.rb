class UserPolicy < ApplicationPolicy
  def index?
    user.is_a?(Admin)
  end

  def show?
    user.is_a?(Admin)
  end

  def update?
    user == record
  end

  def destroy?
    user == record
  end
end
