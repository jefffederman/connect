require "rails_helper"

describe AuthenticationNotifier do
  describe "#integration_name" do
    it "translates to a proper name" do
      notifier = AuthenticationNotifier.new(
        integration_id: "icims",
        installation: installation_spy
      )

      expect(notifier.integration_name).to eq("iCIMS")
    end
  end

  describe "#log_and_notify_of_unauthorized_exception" do
    it "logs the exception" do
      notifier = AuthenticationNotifier.new(
        integration_id: integration_id_stub,
        installation: installation_spy
      )
      exception = Unauthorized.new(Unauthorized::DEFAULT_MESSAGE)

      expect(Rails.logger).to receive(:error).with(
        "#{exception.class} error #{exception.message} for " \
        "installation_id: #{installation_spy.id} " \
        "with #{notifier.integration_name}"
      )

      notifier.log_and_notify_of_unauthorized_exception(exception)
    end

    it "tells installation to send_connection_notification" do
      exception = Unauthorized.new(Unauthorized::DEFAULT_MESSAGE)
      installation = installation_spy

      AuthenticationNotifier.new(
        integration_id: integration_id_stub,
        installation: installation
      ).log_and_notify_of_unauthorized_exception(exception)

      expect(installation).to have_received(
        :send_connection_notification
      ).with(integration_id: integration_id_stub, message: exception.message)
    end
  end

  def integration_id_stub
    "icims"
  end

  def installation_spy
    instance_spy(Installation, id: 1)
  end
end
