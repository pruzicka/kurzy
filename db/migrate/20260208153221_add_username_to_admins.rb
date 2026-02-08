class AddUsernameToAdmins < ActiveRecord::Migration[8.1]
  def change
    add_column :admins, :username, :string, null: false
    add_index :admins, :username, unique: true
  end
end
