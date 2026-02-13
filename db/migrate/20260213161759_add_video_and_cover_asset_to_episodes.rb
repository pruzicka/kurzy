class AddVideoAndCoverAssetToEpisodes < ActiveRecord::Migration[8.1]
  def change
    add_column :episodes, :video_asset_id, :bigint
    add_column :episodes, :cover_asset_id, :bigint
    add_index :episodes, :video_asset_id
    add_index :episodes, :cover_asset_id
  end
end
