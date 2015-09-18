class SyncMailer < ApplicationMailer
  def sync_notification(email:, sync_summary:)
    @integration = I18n.t("#{sync_summary.integration_id}.name")
    @profile_events = sync_summary.profile_events

    mail(
      to: email,
      subject: t(
        "sync_mailer.sync_notification.subject",
        integration: @integration,
        count: @profile_events.successful.count
      )
    )
  end
end
