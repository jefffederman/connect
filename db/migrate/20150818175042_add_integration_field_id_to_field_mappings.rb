class AddIntegrationFieldIdToFieldMappings < ActiveRecord::Migration
  def up
    add_column :field_mappings, :integration_field_id, :string
    update(<<-SQL)
      UPDATE field_mappings SET integration_field_id = integration_field_name
    SQL
    change_column_null :field_mappings, :integration_field_id, false
  end

  def down
    remove_column :field_mappings, :integration_field_id
  end
end
