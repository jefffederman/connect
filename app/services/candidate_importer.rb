class CandidateImporter
  attr_reader :connection, :params

  delegate :success?, to: :import_assistant

  def initialize(
    assistant_arguments: {},
    assistant_class:,
    connection:,
    mailer:,
    params:
  )
    @connection = connection
    @mailer = mailer
    @params = params
    @assistant_class = assistant_class
    @assistant_arguments = assistant_arguments
  end

  def import
    import_assistant.import_candidate
    report_import_results
  end

  def import_assistant
    @import_assistant ||= assistant_class.new(
      assistant_arguments: @assistant_arguments,
      context: self
    )
  end

  def namely_importer
    NamelyImporter.new(
      normalizer: import_assistant.normalizer,
      namely_connection: installation.namely_connection
    )
  end

  def notify_of_unauthorized_exception(exception)
    UnauthorizedNotifier.deliver(
      connection: connection,
      exception: exception
    )
  end

  def installation
    connection.installation
  end

  private

  def notify_of_successful_import
    installation.users.each do |user|
      mailer.delay.successful_import(
        candidate: import_assistant.candidate,
        email: user.email,
        integration_id: assistant_class::INTEGRATION_ID
      )
    end
  end

  def notify_of_unsuccessful_import
    installation.users.each do |user|
      mailer.delay.unsuccessful_import(
        candidate: import_assistant.candidate,
        email: user.email,
        integration_id: assistant_class::INTEGRATION_ID,
        status: import_assistant.import_candidate
      )
    end
  end

  def report_import_results
    if !import_assistant.skip_notification?
      if import_assistant.success?
        notify_of_successful_import
      else
        notify_of_unsuccessful_import
      end
    end
  end

  attr_reader :mailer, :assistant_class
end
