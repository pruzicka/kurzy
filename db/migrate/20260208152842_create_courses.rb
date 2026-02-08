class CreateCourses < ActiveRecord::Migration[8.1]
  def change
    create_table :courses do |t|
      t.string :title, null: false
      t.text :description
      t.string :status, null: false, default: "draft"
      t.integer :price_cents, null: false, default: 0
      t.string :currency, null: false, default: "CZK"
      t.string :slug

      t.timestamps
    end

    add_index :courses, :status
    add_index :courses, :slug, unique: true
  end
end
