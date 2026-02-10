class ChapterPolicy < ApplicationPolicy
  def create?
    user.is_a?(Admin)
  end

  def update?
    user.is_a?(Admin)
  end

  def destroy?
    user.is_a?(Admin)
  end

  def move_up?
    user.is_a?(Admin)
  end

  def move_down?
    user.is_a?(Admin)
  end
end
