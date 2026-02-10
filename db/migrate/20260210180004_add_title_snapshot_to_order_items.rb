class AddTitleSnapshotToOrderItems < ActiveRecord::Migration[8.1]
  def change
    add_column :order_items, :title_snapshot, :string
  end
end
