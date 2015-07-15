class InvalidCandidateImporter
  def initialize(
    assistant_arguments: {},
    assistant_class:,
    connection:,
    mailer:,
    params:
  )
    @connection = connection
    @assistant_class = assistant_class
  end

  def import
    mark_as_error_and_send_notification
  end

  private

  def notifier
    AuthenticationNotifier.new(
      integration_id: assistant_class::INTEGRATION_ID,
      user: user
    )
  end

  def user
    connection.user
  end

  def mark_as_error_and_send_notification
    exception = Unauthorized.new(Unauthorized::DEFAULT_MESSAGE)
    notifier.log_and_notify_of_unauthorized_exception(exception)

    raise exception
  end

  attr_reader :assistant_class, :connection
end
