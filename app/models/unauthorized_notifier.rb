class UnauthorizedNotifier
  def self.deliver(connection:, exception:)
    new(connection: connection, exception: exception).deliver
  end

  def initialize(connection:, exception:)
    @connection = connection
    @exception = exception
  end

  def deliver
    sync_summary = record_sync_summary
    deliver_unauthorized_notification(sync_summary)
  end

  private

  attr_reader :connection, :exception

  def deliver_unauthorized_notification(sync_summary)
    installation.users.each do |user|
      ConnectionMailer.authentication_notification(
        email: user.email,
        sync_summary: sync_summary
      ).deliver_later
    end
  end

  def record_sync_summary
    SyncSummary.create!(
      connection: connection,
      authorization_error: exception.message
    )
  end

  def installation
    connection.installation
  end

  def integration_id
    connection.integration_id
  end
end
