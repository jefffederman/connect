class RetryJob < ActiveJob::Base
  def perform(sync_summary)
    Notifier.execute(sync_summary.connection) do
      sync_summary.retry
    end
  end
end
