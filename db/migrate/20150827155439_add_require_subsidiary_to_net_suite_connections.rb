class AddRequireSubsidiaryToNetSuiteConnections < ActiveRecord::Migration
  def change
    add_column :net_suite_connections, :subsidiary_required, :boolean
  end
end
