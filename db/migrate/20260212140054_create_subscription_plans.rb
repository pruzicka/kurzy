class CreateSubscriptionPlans < ActiveRecord::Migration[8.1]
  def change
    create_table :subscription_plans do |t|
      t.references :author, null: false, foreign_key: true
      t.string :name, null: false
      t.string :slug, null: false
      t.string :status, default: "draft"
      t.integer :monthly_price, null: false, default: 0
      t.string :currency, default: "CZK"
      t.integer :annual_discount_percent, default: 0
      t.string :stripe_product_id
      t.string :stripe_monthly_price_id
      t.string :stripe_annual_price_id

      t.timestamps
    end

    add_index :subscription_plans, :slug, unique: true
  end
end
