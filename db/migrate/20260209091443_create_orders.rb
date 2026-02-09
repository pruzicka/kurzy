class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.string :currency, null: false, default: "CZK"
      t.integer :total_amount, null: false, default: 0
      t.string :stripe_session_id
      t.string :stripe_payment_intent_id

      t.timestamps
    end

    add_index :orders, :stripe_session_id, unique: true
  end
end

