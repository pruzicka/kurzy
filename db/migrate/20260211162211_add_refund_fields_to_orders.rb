class AddRefundFieldsToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :refunded_at, :datetime
    add_column :orders, :refund_reason, :string
    add_column :orders, :fakturoid_correction_id, :integer
    add_column :orders, :fakturoid_correction_number, :string
    add_column :orders, :fakturoid_correction_url, :string
  end
end
