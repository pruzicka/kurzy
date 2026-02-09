class AddCouponsAndDiscounting < ActiveRecord::Migration[8.1]
  def change
    create_table :coupons do |t|
      t.string :code, null: false
      t.string :name
      t.string :discount_type, null: false
      t.integer :value, null: false
      t.string :currency
      t.datetime :starts_at
      t.datetime :ends_at
      t.integer :max_redemptions
      t.integer :redemptions_count, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    add_index :coupons, :code, unique: true
    add_index :coupons, :active

    create_table :coupon_redemptions do |t|
      t.integer :coupon_id, null: false
      t.integer :order_id, null: false
      t.integer :user_id, null: false
      t.datetime :redeemed_at, null: false
      t.timestamps
    end

    add_index :coupon_redemptions, :coupon_id
    add_index :coupon_redemptions, :order_id, unique: true
    add_index :coupon_redemptions, :user_id

    add_foreign_key :coupon_redemptions, :coupons
    add_foreign_key :coupon_redemptions, :orders
    add_foreign_key :coupon_redemptions, :users

    add_column :carts, :coupon_id, :integer
    add_index :carts, :coupon_id
    add_foreign_key :carts, :coupons

    add_column :orders, :coupon_id, :integer
    add_column :orders, :subtotal_amount, :integer, null: false, default: 0
    add_column :orders, :discount_amount, :integer, null: false, default: 0
    add_index :orders, :coupon_id
    add_foreign_key :orders, :coupons
  end
end
