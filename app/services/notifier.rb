class Notifier
  def self.execute(connection, &block)
    new(connection).execute(&block)
  end

  def initialize(connection)
    @connection = connection
  end

  def execute
    yield.tap do |results|
      deliver_sync_notification(results)
    end
  rescue Unauthorized => exception
    deliver_unauthorized_notification(exception)
  end

  private

  attr_reader :connection

  def deliver_sync_notification(results)
    SyncNotifier.deliver(
      results: results,
      installation: connection.installation,
      integration_id: connection.integration_id
    )
  end

  def deliver_unauthorized_notification(exception)
    UnauthorizedNotifier.deliver(
      connection: connection,
      exception: exception
    )
  end
end
