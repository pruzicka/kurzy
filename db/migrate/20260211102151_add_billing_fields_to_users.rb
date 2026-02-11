class AddBillingFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :billing_name, :string
    add_column :users, :billing_street, :string
    add_column :users, :billing_city, :string
    add_column :users, :billing_zip, :string
    add_column :users, :billing_country, :string, default: "CZ"
    add_column :users, :billing_ico, :string
    add_column :users, :billing_dic, :string
  end
end
