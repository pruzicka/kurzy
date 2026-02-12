class SegmentPolicy < ApplicationPolicy
  def show?
    return true if user.is_a?(Admin)
    return true if record.is_free_preview?

    user.is_a?(User) && user.enrollments.active.exists?(course: record.chapter.course)
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

  def move_up?
    user.is_a?(Admin)
  end

  def move_down?
    user.is_a?(Admin)
  end

  def destroy_attachment?
    user.is_a?(Admin)
  end

  def destroy_cover_image?
    user.is_a?(Admin)
  end

  def destroy_video?
    user.is_a?(Admin)
  end

  def destroy_audio?
    user.is_a?(Admin)
  end
end
