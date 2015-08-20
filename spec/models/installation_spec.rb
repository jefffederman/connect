require "rails_helper"

describe Installation do
  describe "validations" do
    subject { create(:installation) }
    it { is_expected.to validate_presence_of(:subdomain) }
    it { is_expected.to validate_uniqueness_of(:subdomain) }
  end

  describe "associations" do
    it { is_expected.to have_many(:users).dependent(:destroy) }
    it { is_expected.to have_one(:greenhouse_connection).dependent(:destroy) }
    it { is_expected.to have_one(:icims_connection).dependent(:destroy) }
    it { is_expected.to have_one(:jobvite_connection).dependent(:destroy) }
    it { is_expected.to have_one(:net_suite_connection).dependent(:destroy) }
  end

  describe ".ready_to_sync_with" do
    it "returns installations ready to connect to the given integration" do
      create_installation(
        :net_suite_connection,
        :connected,
        :with_namely_field,
        subdomain: "ready-with-given-service"
      )
      create_installation(
        :net_suite_connection,
        :connected,
        subdomain: "connected-without-field"
      )
      create_installation(
        :net_suite_connection,
        subdomain: "disconnected"
      )
      create(:installation, subdomain: "uninitialized")
      create_installation(
        :greenhouse_connection,
        :connected,
        :with_namely_field,
        subdomain: "ready-with-different-service"
      )

      result = Installation.ready_to_sync_with(:net_suite)

      expect(result.map(&:subdomain)).to eq(%w(ready-with-given-service))
    end

    def create_installation(factory, *traits, subdomain:)
      installation = create(:installation, subdomain: subdomain)
      create(factory, *traits, installation: installation)
    end
  end

  describe "#jobvite_connection" do
    it "returns the existing Jobvite::Connection when one exists" do
      installation = create(:installation)

      jobvite_connection = create(
        :jobvite_connection,
        installation: installation
      )

      expect(installation.jobvite_connection).to eq jobvite_connection
    end

    it "creates a new Jobvite::Connection when one doesn't exist" do
      installation = create(:installation)

      jobvite_connection = installation.jobvite_connection

      expect(jobvite_connection).to be_a Jobvite::Connection
      expect(jobvite_connection).to be_persisted
      expect(jobvite_connection.installation_id).to eq installation.id
    end
  end

  describe "#net_suite_connection" do
    context "with an existing connection" do
      it "returns the existing connection" do
        installation = create(:installation)

        net_suite_connection = create(
          :net_suite_connection,
          installation: installation
        )

        expect(installation.net_suite_connection).to eq net_suite_connection
      end
    end

    context "with no existing connection" do
      it "creates a new connection" do
        installation = create(:installation)

        net_suite_connection = installation.net_suite_connection

        expect(net_suite_connection).to be_a NetSuite::Connection
        expect(net_suite_connection).to be_persisted
        expect(net_suite_connection.installation_id).to eq installation.id
      end
    end
  end

  describe "#send_connection_notification" do
    it "delegates to each users" do
      users = [build_stubbed(:user), build_stubbed(:user)]
      stub_each(users, :send_connection_notification)
      message = "Whoops"
      installation = Installation.new(users: users)

      installation.send_connection_notification(
        integration_id: "icims",
        message: message
      )

      users.each do |user|
        expect(user).
          to have_received(:send_connection_notification).
          with(integration_id: "icims", message: message)
      end
    end
  end

  describe "#namely_connection" do
    it "delegates to its first user" do
      users = [build_stubbed(:user), build_stubbed(:user)]
      namely_connection = double(namely_connection)
      allow(users.first).
        to receive(:namely_connection).
        and_return(namely_connection)
      installation = Installation.new(users: users)

      result = installation.namely_connection

      expect(result).to eq(namely_connection)
    end
  end

  describe "#namely_profiles" do
    it "delegates to its first user" do
      users = [build_stubbed(:user), build_stubbed(:user)]
      namely_profiles = double(namely_profiles)
      allow(users.first).
        to receive(:namely_profiles).
        and_return(namely_profiles)
      installation = Installation.new(users: users)

      result = installation.namely_profiles

      expect(result).to eq(namely_profiles)
    end
  end

  def stub_each(array, method_name)
    array.each do |item|
      allow(item).to receive(method_name)
    end
  end
end
