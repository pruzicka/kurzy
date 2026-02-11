class AddFakturoidFieldsToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :fakturoid_invoice_id, :integer
    add_column :orders, :fakturoid_invoice_number, :string
    add_column :orders, :fakturoid_public_url, :string
    add_column :orders, :fakturoid_private_url, :string
    add_column :orders, :fakturoid_subject_id, :integer
    add_column :orders, :billing_name, :string
    add_column :orders, :billing_street, :string
    add_column :orders, :billing_city, :string
    add_column :orders, :billing_zip, :string
    add_column :orders, :billing_country, :string
    add_column :orders, :billing_ico, :string
    add_column :orders, :billing_dic, :string

    add_index :orders, :fakturoid_invoice_id, unique: true
  end
end
