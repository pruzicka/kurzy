class AddLockableToAdmins < ActiveRecord::Migration[8.1]
  def change
    add_column :admins, :failed_attempts, :integer, default: 0, null: false
    add_column :admins, :unlock_token, :string
    add_index :admins, :unlock_token, unique: true
    add_column :admins, :locked_at, :datetime
  end
end
