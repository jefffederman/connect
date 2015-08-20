class MoveAttributeMappersToInstallations < ActiveRecord::Migration
  def up
    remove_column :attribute_mappers, :user_id
  end

  def down
    add_column :attribute_mappers, :user_id, :integer

    update(<<-SQL)
      UPDATE attribute_mappers
      SET user_id = (
        SELECT users.id
        FROM users
        INNER JOIN installations
          ON installations.id = users.installation_id
        LEFT JOIN jobvite_connections
          ON jobvite_connections.installation_id = installations.id
        LEFT JOIN net_suite_connections
          ON net_suite_connections.installation_id = installations.id
        WHERE attribute_mappers.id = jobvite_connections.attribute_mapper_id
          OR attribute_mappers.id = net_suite_connections.attribute_mapper_id
        LIMIT 1
      )
    SQL

    change_column_null :attribute_mappers, :user_id, false
  end
end
