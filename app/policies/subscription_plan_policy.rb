class SubscriptionPlanPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.is_a?(Admin)
  end

  def update?
    user.is_a?(Admin)
  end

  def destroy?
    user.is_a?(Admin)
  end

  def destroy_cover_image?
    user.is_a?(Admin)
  end
end
