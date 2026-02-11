class CreateBillingCompanies < ActiveRecord::Migration[8.1]
  def change
    create_table :billing_companies do |t|
      t.string :name, null: false
      t.string :street
      t.string :city
      t.string :zip
      t.string :country, default: "CZ"
      t.string :ico
      t.string :dic
      t.string :fakturoid_slug
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
