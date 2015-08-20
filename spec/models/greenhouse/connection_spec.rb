require 'rails_helper'

RSpec.describe Greenhouse::Connection, :type => :model do
  describe "associations" do
    subject { build(:greenhouse_connection) }
    it { is_expected.to belong_to(:installation) }
    it { is_expected.to validate_uniqueness_of(:secret_key) }
  end

  describe "#connected?" do
    it "returns true when name is set" do
      greenhouse_connection = described_class.new(
        name: "webhook"
      )

      expect(greenhouse_connection).to be_connected
    end

    it "returns false when name is missing" do
      expect(described_class.new).not_to be_connected
    end
  end

  describe '#secret_key' do
    it 'generates a secret key' do
      greenhouse_connection = create :greenhouse_connection, :connected
      expect(greenhouse_connection.secret_key).to_not be_nil
    end
  end
end
