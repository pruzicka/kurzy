class CreateSegments < ActiveRecord::Migration[8.1]
  def change
    create_table :segments do |t|
      t.references :course, null: false, foreign_key: true
      t.string :title, null: false
      t.integer :position, null: false
      t.boolean :is_mandatory, null: false, default: false

      t.timestamps
    end

    add_index :segments, %i[course_id position], unique: true
  end
end
