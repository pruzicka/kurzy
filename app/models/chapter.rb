class Chapter < ApplicationRecord
  belongs_to :course

  has_many :segments, -> { order(position: :asc) }, dependent: :destroy

  validates :title, presence: true
  validates :position, numericality: { only_integer: true, greater_than: 0 }

  before_validation :assign_position, on: :create

  def move_up!
    neighbor = course.chapters.where("position < ?", position).order(position: :desc).first
    return unless neighbor
    swap_positions!(neighbor)
  end

  def move_down!
    neighbor = course.chapters.where("position > ?", position).order(position: :asc).first
    return unless neighbor
    swap_positions!(neighbor)
  end

  private

  def assign_position
    self.position ||= (course.chapters.maximum(:position) || 0) + 1
  end

  def swap_positions!(other)
    Chapter.transaction do
      current = position
      other_position = other.position

      # Avoid unique index violation on (course_id, position) during swap.
      update_columns(position: 0)
      other.update_columns(position: current)
      update_columns(position: other_position)
    end
  end
end
