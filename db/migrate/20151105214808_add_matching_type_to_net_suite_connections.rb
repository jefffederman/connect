class AddMatchingTypeToNetSuiteConnections < ActiveRecord::Migration
  def change
    add_column :net_suite_connections, :matching_type, :integer, null: false, default: 0
  end
end
