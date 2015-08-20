class BulkSync
  def initialize(integration_id:, installations:)
    @integration_id = integration_id
    @installations = installations
  end

  def sync
    @installations.ready_to_sync_with(@integration_id).each do |installations|
      Delayed::Job.enqueue SyncJob.new(@integration_id, installations.id)
    end
  end
end
