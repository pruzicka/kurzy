class AddAudioAssetToSegmentsAndEpisodes < ActiveRecord::Migration[8.1]
  def change
    add_reference :segments, :audio_asset, foreign_key: { to_table: :media_assets }, null: true
    add_reference :episodes, :audio_asset, foreign_key: { to_table: :media_assets }, null: true
  end
end
