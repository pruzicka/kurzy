class AddStatusToEnrollments < ActiveRecord::Migration[8.1]
  def change
    add_column :enrollments, :status, :string, null: false, default: "active"
    add_column :enrollments, :revoked_at, :datetime
    add_index :enrollments, :status
  end
end
