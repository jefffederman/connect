require 'rails_helper'

RSpec.describe Greenhouse::Connection, :type => :model do
  describe "associations" do
    subject { build(:greenhouse_connection) }
    it { is_expected.to belong_to(:attribute_mapper).dependent(:destroy) }
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

  describe "#attribute_mapper" do
    it "builds and saves an attribute mapper" do
      installation = build(:installation)
      connection = Greenhouse::Connection.new(
        installation: installation,
        name: "example"
      )

      connection.save!

      expect(connection.attribute_mapper).to be_an_instance_of(AttributeMapper)
      expect(connection.attribute_mapper).to be_persisted
      expect(mapped_fields(connection.attribute_mapper)).to match_array([
        %w(first_name first_name),
        %w(middle_name middle_name),
        %w(last_name last_name),
        %w(work_email email),
        %w(personal_email personal_email),
        %w(starts_at start_date),
      ])
    end
  end

  def mapped_fields(attribute_mapper)
    attribute_mapper.field_mappings.map do |field_mapping|
      [field_mapping.integration_field_id, field_mapping.namely_field_name]
    end
  end
end
