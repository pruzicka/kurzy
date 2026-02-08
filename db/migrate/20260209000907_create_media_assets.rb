class CreateMediaAssets < ActiveRecord::Migration[8.1]
  def change
    create_table :media_assets do |t|
      t.string :title, null: false
      t.string :media_type, null: false
      t.text :notes

      t.timestamps
    end

    add_index :media_assets, :media_type
  end
end

