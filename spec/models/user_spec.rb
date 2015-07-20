require "rails_helper"

describe User do
  describe "associations" do
    it { should have_one(:greenhouse_connection) }
    it { should have_one(:jobvite_connection) }
    it { should have_one(:icims_connection) }
    it { should have_one(:net_suite_connection) }
    it { should have_many(:attribute_mappers) }
  end

  describe "#jobvite_connection" do
    it "returns the existing Jobvite::Connection when one exists" do
      user = create(:user)

      jobvite_connection = create(:jobvite_connection, user: user)

      expect(user.jobvite_connection).to eq jobvite_connection
    end

    it "creates a new Jobvite::Connection when one doesn't exist" do
      user = create(:user)

      jobvite_connection = user.jobvite_connection

      expect(jobvite_connection).to be_a Jobvite::Connection
      expect(jobvite_connection).to be_persisted
      expect(jobvite_connection.user_id).to eq user.id
    end
  end

  describe "#net_suite_connection" do
    context "with an existing connection" do
      it "returns the existing connection" do
        user = create(:user)

        net_suite_connection = create(:net_suite_connection, user: user)

        expect(user.net_suite_connection).to eq net_suite_connection
      end
    end

    context "with no existing connection" do
      it "creates a new connection" do
        user = create(:user)

        net_suite_connection = user.net_suite_connection

        expect(net_suite_connection).to be_a NetSuite::Connection
        expect(net_suite_connection).to be_persisted
        expect(net_suite_connection.user_id).to eq user.id
      end
    end
  end

  describe "#namely_connection" do
    it "returns a Namely::Connection configured to use the user's credentials" do
      namely_connection = double("Namely::Connection")
      allow(Namely::Connection).to receive(:new).and_return(namely_connection)
      user = build(
        :user,
        access_token: "MY_ACCESS_TOKEN",
        subdomain: "ellingsonmineral",
      )

      result = user.namely_connection

      expect(result).to eq namely_connection
      expect(Namely::Connection).to have_received(:new).with(
        access_token: "MY_ACCESS_TOKEN",
        subdomain: "ellingsonmineral",
      )
    end
  end

  describe "#send_connection_notification" do
    it "sends an invalid authentication message" do
      user = build_stubbed(:user)
      mail = double(ConnectionMailer, deliver: true)
      exception = Unauthorized.new("Whoops")
      allow(ConnectionMailer).
        to receive(:authentication_notification).
        with(
          email: user.email,
          integration_id: "icims",
          message: exception.message,
        ).
        and_return(mail)

      user.send_connection_notification(
        integration_id: "icims",
        message: exception.message
      )

      expect(mail).to have_received(:deliver)
    end
  end

  describe '#save_token_info' do 
    let(:user) { create :user }

    it 'saves new access token and access token expires in info' do 
      user.save_token_info('new_token', 'new_time')

      expect(user.access_token).to eql 'new_token'
    end
  end

  describe ".ready_to_sync_with" do
    it "returns users with a ready connection to the given integration" do
      user = create(:user, first_name: "ready-with-given-service")
      create(:net_suite_connection, :connected, :with_namely_field, user: user)
      user = create(:user, first_name: "connected-without-field")
      create(:net_suite_connection, :connected, user: user)
      user = create(:user, first_name: "disconnected")
      create(:net_suite_connection, user: user)
      create(:user, first_name: "uninitialized")
      user = create(:user, first_name: "ready-with-different-service")
      create(:greenhouse_connection, :connected, :with_namely_field, user: user)

      result = User.ready_to_sync_with(:net_suite)

      expect(result.map(&:first_name)).to eq(%w(ready-with-given-service))
    end
  end

  describe "#namely_profiles" do
    it "returns profiles from its Namely connection" do
      profiles = double(:namely_profiles)
      stub_namely_connection profiles: profiles
      user = User.new

      result = user.namely_profiles

      expect(result).to eq(profiles)
    end
  end

  describe "#namely_fields" do
    it "returns fields from its Namely connection" do
      fields = double(:namely_fields)
      stub_namely_connection fields: fields
      user = User.new

      result = user.namely_fields

      expect(result).to eq(fields)
    end
  end

  def stub_namely_connection(attributes)
    namely_connection = double(:namely_connection, attributes)
    allow(Namely::Connection).to receive(:new).and_return(namely_connection)
    allow(Users::AccessTokenFreshener).to receive(:fresh_access_token)
  end
end
