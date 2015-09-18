require "rails_helper"

describe UnauthorizedNotifier do
  describe ".deliver" do
    it "records a sync summary and emails each user of the installation" do
      user = create(:user)
      installation = create(:installation, users: [user])
      connection = create(:net_suite_connection, installation: installation)
      exception = double(:exception, message: "failed")
      allow(ConnectionMailer).to receive(:authentication_notification).
        and_return(double(:mailer, deliver_later: true))

      UnauthorizedNotifier.deliver(
        connection: connection,
        exception: exception
      )
      summary = SyncSummary.find_by(
        connection: connection,
        authorization_error: exception.message
      )

      expect(summary).to be_present
      expect(ConnectionMailer).to(
        have_received(:authentication_notification).
          with(email: user.email, sync_summary: summary)
      )
    end
  end
end
