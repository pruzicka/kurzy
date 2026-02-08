class RecreateCourseProgressesWithCorrectForeignKey < ActiveRecord::Migration[8.1]
  def change
    # Safety migration:
    # Older versions of this repo created an incorrect FK for last_segment_id.
    # Fix it without dropping data.
    return unless table_exists?(:course_progresses)

    if foreign_key_exists?(:course_progresses, column: :last_segment_id)
      remove_foreign_key :course_progresses, column: :last_segment_id
    end

    unless foreign_key_exists?(:course_progresses, :segments, column: :last_segment_id)
      add_foreign_key :course_progresses, :segments, column: :last_segment_id
    end

    unless index_exists?(:course_progresses, [:user_id, :course_id], unique: true)
      add_index :course_progresses, [:user_id, :course_id], unique: true
    end
  end
end
