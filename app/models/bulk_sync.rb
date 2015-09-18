class BulkSync
  def self.sync(integration_id)
    new(integration_id: integration_id, installations: Installation.all).sync
  end

  def initialize(integration_id:, installations:)
    @integration_id = integration_id
    @installations = installations
  end

  def sync
    @installations.ready_to_sync_with(@integration_id).each do |installation|
      connection = installation.connection_to(@integration_id)
      SyncJob.perform_later(connection)
    end
  end
end
