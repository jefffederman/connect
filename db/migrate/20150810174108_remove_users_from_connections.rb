class RemoveUsersFromConnections < ActiveRecord::Migration
  def up
    remove_column :greenhouse_connections, :user_id
    remove_column :icims_connections, :user_id
    remove_column :jobvite_connections, :user_id
    remove_column :net_suite_connections, :user_id
  end

  def down
    add_user_id_to :greenhouse_connections
    add_user_id_to :icims_connections
    add_user_id_to :jobvite_connections
    add_user_id_to :net_suite_connections
  end

  private

  def add_user_id_to(table_name)
    add_column table_name, :user_id, :integer

    update(<<-SQL)
      UPDATE #{table_name}
      SET user_id = (
        SELECT users.id
        FROM users
        WHERE users.installation_id = #{table_name}.id
        LIMIT 1
      )
    SQL

    change_column_null table_name, :user_id, false
  end
end
