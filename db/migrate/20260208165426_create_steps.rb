class CreateSteps < ActiveRecord::Migration[8.1]
  def change
    create_table :steps do |t|
      t.references :segment, null: false, foreign_key: true
      t.string :title, null: false
      t.text :content
      t.integer :position, null: false

      t.timestamps
    end

    add_index :steps, %i[segment_id position], unique: true
  end
end
