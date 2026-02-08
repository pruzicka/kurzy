class CreateSegmentCompletions < ActiveRecord::Migration[8.1]
  def change
    create_table :segment_completions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :segment, null: false, foreign_key: true
      t.datetime :completed_at

      t.timestamps
    end

    add_index :segment_completions, [:user_id, :segment_id], unique: true
  end
end
