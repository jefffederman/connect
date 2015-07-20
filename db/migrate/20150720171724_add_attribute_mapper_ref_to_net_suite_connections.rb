class AddAttributeMapperRefToNetSuiteConnections < ActiveRecord::Migration
  def change
    add_reference(
      :net_suite_connections,
      :attribute_mapper,
      foreign_key: true,
      index: true
    )
  end
end
