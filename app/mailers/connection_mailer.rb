class ConnectionMailer < ApplicationMailer
  def authentication_notification(email:, sync_summary:)
    @integration = map_integration_id_to_name(sync_summary.integration_id)
    @message = sync_summary.authorization_error

    mail(
      to: email,
      subject: t(
        "connection_mailer.authentication_notification.subject",
        integration: @integration
      )
    )
  end
end
