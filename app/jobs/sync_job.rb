class SyncJob < ActiveJob::Base
  def perform(connection)
    Notifier.execute(connection) do
      connection.sync
    end
  end
end
