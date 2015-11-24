class AddLockedToNetSuiteConnections < ActiveRecord::Migration
  def change
    add_column :net_suite_connections, :locked, :boolean, default: false, null: false
  end
end
