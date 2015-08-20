class AdjustUserAddReferenceToInstallation < ActiveRecord::Migration
  def up
    add_reference :users, :installation, index: true, foreign_key: true

    update(<<-SQL)
      UPDATE users SET installation_id = (
        SELECT installations.id
        FROM installations
        WHERE installations.subdomain = users.subdomain
      )
    SQL

    change_column_null :users, :installation_id, false
  end

  def down
    remove_reference :users, :installation
  end
end
