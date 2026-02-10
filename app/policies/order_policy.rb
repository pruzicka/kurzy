class OrderPolicy < ApplicationPolicy
  def index?
    user.is_a?(Admin)
  end

  def show?
    user.is_a?(Admin) || user == record.user
  end

  def destroy?
    user.is_a?(Admin) && (record.status == "pending" || record.status == "canceled")
  end
end
