require "rails_helper"

describe CandidateImporter do
  describe "#initialize" do
    context "greenhouse" do
      it "will pass extra paramenters on to the import assistant" do
        importer = CandidateImporter.new(
          connection: connection_double,
          mailer: mailer_double,
          params: {},
          assistant_class: Greenhouse::CandidateImportAssistant,
          assistant_arguments: { signature: "foo" }
        )

        expect(Greenhouse::CandidateImportAssistant).to receive(:new).with(
          assistant_arguments: { signature: "foo" },
          context: importer,
        )

        importer.import_assistant
      end
    end
  end

  describe "#import" do
    context "successful imports" do
      it "enqueues a successful mail delivery" do
        candidate = candidate_double
        user = user_double
        installation = installation_double(users: [user])
        connection = connection_double(installation: installation)
        params = {}
        mailer = mailer_double
        assistant_class = Icims::CandidateImportAssistant

        importer = CandidateImporter.new(
          connection: connection,
          mailer: mailer,
          params: params,
          assistant_class: assistant_class
        )

        allow(importer.import_assistant).to receive(:candidate).
          and_return(candidate)

        expect(mailer.delay).to receive(:successful_import).
          with(
            candidate: candidate,
            email: user.email,
            integration_id: assistant_class::INTEGRATION_ID
          )

        importer.import
      end
    end

    context "unsuccessful imports" do
      it "enqueues an unsuccessful mail delivery" do
        namely_profiles = double(:profiles)
        allow(namely_profiles).to receive(:create!).
          and_raise(Namely::FailedRequestError.new)

        namely_connection = namely_connection_double
        allow(namely_connection).to receive(:profiles).
          and_return(namely_profiles)

        user = user_double

        installation = installation_double(users: [user])
        allow(installation).to receive(:namely_connection).
          and_return(namely_connection)

        connection = connection_double
        allow(connection).to receive(:installation).and_return(installation)
        candidate = candidate_double
        mailer = mailer_double
        assistant_class = Icims::CandidateImportAssistant

        importer = CandidateImporter.new(
          connection: connection,
          mailer: mailer,
          params: {},
          assistant_class: Icims::CandidateImportAssistant
        )

        allow(importer.import_assistant).to receive(:candidate).
          and_return(candidate)

        expect(mailer.delay).to receive(:unsuccessful_import).
          with(
            candidate: candidate,
            email: user.email,
            integration_id: assistant_class::INTEGRATION_ID,
            status: importer.import_assistant.import_candidate
          )

        importer.import
      end
    end

    context "with bad credentials for the integration" do
      context "greenhouse" do
        it "logs the error and sends an authentication notifcation email" do
          connection = connection_double(integration_id: "greenhouse")
          mailer = mailer_double
          params = { payload: { web_hook_id: -1 } }

          importer = CandidateImporter.new(
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

          expect(UnauthorizedNotifier).to receive(:deliver)
          expect(mailer.delay).not_to receive(:successful_import)
          expect(mailer.delay).not_to receive(:unsuccessful_import)

          expect { importer.import }.to raise_error(Unauthorized)
        end
      end

      context "icims" do
        it "logs the error and sends an authentication notification email" do
          exception = Icims::Client::Error.new("Unauthorized")
          allow_any_instance_of(Icims::Client).
            to(receive(:candidate) { raise exception })

          connection = connection_double(integration_id: "icims")
          mailer = mailer_double

          importer = CandidateImporter.new(
            connection: connection,
            mailer: mailer,
            params: {},
            assistant_class: Icims::CandidateImportAssistant
          )

          expect(UnauthorizedNotifier).to receive(:deliver)
          expect(mailer.delay).not_to receive(:successful_import)
          expect(mailer.delay).not_to receive(:unsuccessful_import)

          importer.import
        end
      end
    end
  end

  def candidate_double
    double(
      :candidate,
      email: "firstlast@example.com",
      firstname: "First",
      gender: "Alien",
      home_address: "Et",
      id: -1,
      lastname: "Last",
      start_date: "start_date",
    )
  end

  def connection_double(installation: installation_double, integration_id: "")
    double(
      :connection,
      installation: installation,
      integration_id: integration_id
    )
  end

  def delayed_double
    double(
      :delayed,
      successful_import: true,
      unsuccessful_import: true
    )
  end

  def mailer_double
    double(:mailer, delay: delayed_double)
  end

  def namely_connection_double
    double(:namely_connection, profiles: double(:profiles, create!: true))
  end

  def installation_double(users: [])
    double(
      :installation,
      id: -1,
      namely_connection: namely_connection_double,
      users: users
    )
  end

  def user_double
    double(
      :user,
      id: -1,
      email: "user@example.com"
    )
  end
end
