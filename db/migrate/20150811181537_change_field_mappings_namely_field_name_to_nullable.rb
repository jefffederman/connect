class ChangeFieldMappingsNamelyFieldNameToNullable < ActiveRecord::Migration
  def up
    change_column_null :field_mappings, :namely_field_name, true
  end

  def down
    delete(<<-SQL)
      DELETE FROM field_mappings WHERE namely_field_name IS NULL
    SQL
    change_column_null :field_mappings, :namely_field_name, true
  end
end
