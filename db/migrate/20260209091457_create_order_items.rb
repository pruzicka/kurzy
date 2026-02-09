class CreateOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1
      t.integer :unit_amount, null: false
      t.string :currency, null: false, default: "CZK"

      t.timestamps
    end
  end
end

