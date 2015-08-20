class AddAttributeMapperIdToJobviteConnections < ActiveRecord::Migration
  def change
    add_reference(
      :jobvite_connections,
      :attribute_mapper,
      foreign_key: true,
      index: true
    )
  end
end
