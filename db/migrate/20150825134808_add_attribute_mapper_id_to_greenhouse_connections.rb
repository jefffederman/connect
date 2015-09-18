class AddAttributeMapperIdToGreenhouseConnections < ActiveRecord::Migration
  def change
    add_column :greenhouse_connections, :attribute_mapper_id, :integer
  end
end
