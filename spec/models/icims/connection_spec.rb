require "rails_helper"

describe Icims::Connection do
  describe "associations" do
    subject { build(:icims_connection) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_uniqueness_of(:api_key) }
  end

  describe "#connected?" do
    it "returns true when the username and password are set" do
      icims_connection = described_class.new(
        customer_id: 1,
        key: "some key",
        username: "username",
      )

      expect(icims_connection).to be_connected
    end

    it "returns false when the username or password is missing" do
      expect(described_class.new).not_to be_connected
      expect(described_class.new(username: "username")).not_to be_connected
      expect(described_class.new(customer_id: 1)).not_to be_connected
      expect(described_class.new(key: "key")).not_to be_connected
    end
  end

  describe "#disconnect" do
    it "sets the username,key and customer_id to nil" do
      icims_connection = create(
        :icims_connection,
        username: "crashoverride",
      )

      icims_connection.disconnect

      expect(icims_connection.customer_id).to be_nil
      expect(icims_connection.key).to be_nil
      expect(icims_connection.username).to be_nil
    end
  end

  describe "#build_candidate_importer" do
    it "constructs a valid CandidateImporter when connected" do
      icims_connection = create(:icims_connection)
      importer = icims_connection.build_candidate_importer(
        assistant_class: double("assistant_class"),
        connection: double("connection"),
        mailer: double("mailer"),
        params: double("params")
      )
      expect(importer.class).to eq CandidateImporter
    end
  end

  describe ".for_api_key" do
    it "constructs a valid connection when given valid credentials" do
      existing = create(:icims_connection)
      connection = described_class.for_api_key(
        api_key: existing.api_key, customer_id: existing.customer_id)
      importer = connection.build_candidate_importer(
        assistant_class: double("assistant_class"),
        connection: double("connection"),
        mailer: double("mailer"),
        params: double("params")
      )

      expect(importer.class).to eq CandidateImporter
    end

    it "constructs a missing connection when it cannot find the credentials" do
      connection = described_class.for_api_key(api_key: 1, customer_id: 2)
      importer = connection.build_candidate_importer(
        assistant_class: double("assistant_class"),
        connection: double("connection"),
        mailer: double("mailer"),
        params: double("params")
      )

      expect(importer.class).to eq InvalidCandidateImporter
    end
  end
end
