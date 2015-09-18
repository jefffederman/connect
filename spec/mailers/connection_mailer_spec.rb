require "rails_helper"

describe ConnectionMailer do
  it "provides integration name in the subject, addresses the email, and " \
  "describes the problem" do
    sync_summary = create(
      :sync_summary,
      connection: create(:icims_connection),
      authorization_error: "Foo"
    )
    email = "test@example.com"

    mailer = ConnectionMailer.authentication_notification(
      email: email,
      sync_summary: sync_summary
    )

    expect(mailer.subject).to eq(
      t(
        "connection_mailer.authentication_notification.subject",
        integration: "iCIMS"
      )
    )
    expect(mailer.to).to match_array([email])
    expect(mailer.body.to_s).to include(
      t(
        "connection_mailer.authentication_notification.notice",
        integration: "iCIMS"
      )
    )
    expect(mailer.body.to_s).to include(
      t(
        "connection_mailer.authentication_notification.error_message",
        message: sync_summary.authorization_error
      )
    )
  end
end
