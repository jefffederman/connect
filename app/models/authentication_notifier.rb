class AuthenticationNotifier
  def initialize(integration_id:, user:)
    @integration_id = integration_id
    @user = user
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
    user.send_connection_notification(
      connection_type: integration_id,
      message: exception.message
    )
  end

  def log_unauthorized_exception(exception)
    Rails.logger.error(
      "#{exception.class} error #{exception.message} for " \
      "user_id: #{user.id} with #{integration_name}"
    )
  end

  attr_reader :integration_id, :user
end
