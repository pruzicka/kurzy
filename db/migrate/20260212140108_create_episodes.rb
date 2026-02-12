class CreateEpisodes < ActiveRecord::Migration[8.1]
  def change
    create_table :episodes do |t|
      t.references :subscription_plan, null: false, foreign_key: true
      t.string :title, null: false
      t.string :status, default: "draft"
      t.integer :position, null: false
      t.datetime :published_at

      t.timestamps
    end

    add_index :episodes, [:subscription_plan_id, :position], unique: true
  end
end
