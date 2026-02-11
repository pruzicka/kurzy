class AddTwoFactorToAdmins < ActiveRecord::Migration[8.1]
  def change
    add_column :admins, :otp_secret, :string
    add_column :admins, :otp_required_for_login, :boolean, default: false
    add_column :admins, :otp_backup_codes, :string, array: true, default: []
    add_column :admins, :consumed_timestep, :integer
  end
end
