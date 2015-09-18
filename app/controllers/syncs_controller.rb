class SyncsController < IntegrationController
  def create
    SyncJob.perform_later(connection)
  end
end
