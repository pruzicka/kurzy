class AddMediaAssetRefsToSegments < ActiveRecord::Migration[8.1]
  def change
    add_reference :segments, :video_asset, foreign_key: { to_table: :media_assets }
    add_reference :segments, :cover_asset, foreign_key: { to_table: :media_assets }
  end
end

