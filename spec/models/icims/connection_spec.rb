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
end
