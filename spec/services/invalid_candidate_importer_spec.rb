require "rails_helper"

describe InvalidCandidateImporter do
  it "logs the error and sends an authentication notifcation email" do
    exception = Unauthorized.new(Unauthorized::DEFAULT_MESSAGE)

    connection = connection_double
    mailer = mailer_double
    params = { payload: { web_hook_id: -1 } }
    user = connection.user
    user_id = user.id

    importer = InvalidCandidateImporter.new(
      assistant_arguments: { signature: "foo" },
      assistant_class: Greenhouse::CandidateImportAssistant,
      connection: connection,
      mailer: mailer,
      params: params,
    )

    policy_double = double(:valid_requester_policy, valid?: false)
    allow(Greenhouse::ValidRequesterPolicy).to receive(:new).
      with(
        connection,
        "foo",
        params
    ).and_return(policy_double)

      allow(user).to receive(:send_connection_notification).
        with(integration_id: "greenhouse", message: exception.message)
      expect(Rails.logger).to receive(:error).with(
        "Unauthorized error Invalid authentication for " \
        "user_id: #{user_id} with Greenhouse"
      )
      expect(user).to receive(:send_connection_notification).
        with(integration_id: "greenhouse", message: exception.message)
      expect(mailer.delay).not_to receive(:successful_import)
      expect(mailer.delay).not_to receive(:unsuccessful_import)

      expect { importer.import }.to raise_error(Unauthorized)
  end

  def connection_double
    double(:connection, user: user_double)
  end

  def user_double
    double(
      :user,
      email: "test@example.com",
      id: -1,
      namely_connection: namely_connection_double
    )
  end

  def namely_connection_double
    double(:namely_connection, profiles: double(:profiles, create!: true))
  end

  def mailer_double
    double(:mailer, delay: delayed_double)
  end

  def delayed_double
    double(
      :delayed,
      successful_import: true,
      unsuccessful_import: true
    )
  end
end
