class AddAuthorToCourses < ActiveRecord::Migration[8.1]
  def change
    add_reference :courses, :author, foreign_key: true, null: true
  end
end
