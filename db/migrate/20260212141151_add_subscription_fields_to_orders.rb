class AddSubscriptionFieldsToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :order_type, :string, default: "one_time", null: false
    add_reference :orders, :subscription, foreign_key: true, null: true
  end
end
