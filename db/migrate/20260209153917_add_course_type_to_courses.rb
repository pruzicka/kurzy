class AddCourseTypeToCourses < ActiveRecord::Migration[8.1]
  def change
    add_column :courses, :course_type, :string, null: false, default: "online_course"
    add_index :courses, :course_type
  end
end

