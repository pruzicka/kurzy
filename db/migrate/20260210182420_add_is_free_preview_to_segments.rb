class AddIsFreePreviewToSegments < ActiveRecord::Migration[8.1]
  def change
    add_column :segments, :is_free_preview, :boolean, null: false, default: false
  end
end
