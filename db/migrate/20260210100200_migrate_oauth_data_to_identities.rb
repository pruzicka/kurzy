class MigrateOauthDataToIdentities < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      INSERT INTO oauth_identities (user_id, provider, uid, email, created_at, updated_at)
      SELECT id, provider, uid, email, created_at, updated_at
      FROM users
      WHERE provider IS NOT NULL AND uid IS NOT NULL
    SQL

    change_column_null :users, :provider, true
    change_column_null :users, :uid, true
  end

  def down
    change_column_null :users, :provider, false
    change_column_null :users, :uid, false

    execute "DELETE FROM oauth_identities"
  end
end
