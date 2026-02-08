class CreateCourseProgresses < ActiveRecord::Migration[8.1]
  def change
    create_table :course_progresses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.references :last_segment, null: false, foreign_key: { to_table: :segments }

      t.timestamps
    end

    add_index :course_progresses, [:user_id, :course_id], unique: true
  end
end
