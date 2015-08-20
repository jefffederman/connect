class AuthenticationNotifier
  def initialize(integration_id:, installation:)
    @integration_id = integration_id
    @installation = installation
  end

  def integration_name
    I18n.t("#{integration_id}.name")
  end

  def log_and_notify_of_unauthorized_exception(exception)
    log_unauthorized_exception(exception)
    deliver_unauthorized_notification(exception)
  end

  private

  def deliver_unauthorized_notification(exception)
    installation.send_connection_notification(
      integration_id: integration_id,
      message: exception.message
    )
  end

  def log_unauthorized_exception(exception)
    Rails.logger.error(
      "#{exception.class} error #{exception.message} for " \
      "installation_id: #{installation.id} with #{integration_name}"
    )
  end

  attr_reader :integration_id, :installation
end
