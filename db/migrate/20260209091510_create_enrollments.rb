class CreateEnrollments < ActiveRecord::Migration[8.1]
  def change
    create_table :enrollments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true
      t.datetime :granted_at, null: false

      t.timestamps
    end

    add_index :enrollments, [:user_id, :course_id], unique: true
  end
end

