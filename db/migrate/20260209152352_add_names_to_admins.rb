class AddNamesToAdmins < ActiveRecord::Migration[8.1]
  def change
    add_column :admins, :first_name, :string
    add_column :admins, :last_name, :string
  end
end

