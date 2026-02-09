class AddNotesToCoupons < ActiveRecord::Migration[8.1]
  def change
    add_column :coupons, :notes, :string
  end
end
