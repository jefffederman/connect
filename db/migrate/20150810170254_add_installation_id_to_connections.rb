class AddInstallationIdToConnections < ActiveRecord::Migration
  def up
    add_installation_id_to :greenhouse_connections
    add_installation_id_to :icims_connections
    add_installation_id_to :jobvite_connections
    add_installation_id_to :net_suite_connections
  end

  def down
    remove_installation_id_from :net_suite_connections
    remove_installation_id_from :jobvite_connections
    remove_installation_id_from :icims_connections
    remove_installation_id_from :greenhouse_connections
  end

  private

  def add_installation_id_to(table_name)
    add_reference(
      table_name,
      :installation,
      foreign_key: true,
      index: true,
      null: true,
      unique: true
    )

    update(<<-SQL)
      UPDATE #{table_name}
      SET installation_id = (
        SELECT users.installation_id
        FROM users
        WHERE #{table_name}.user_id = users.id
        ORDER BY updated_at DESC
        LIMIT 1
      )
    SQL

    change_column_null table_name, :installation_id, false
  end

  def remove_installation_id_from(table_name)
    remove_reference table_name, :installation
  end
end
