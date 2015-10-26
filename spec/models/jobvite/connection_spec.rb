require "rails_helper"

describe Jobvite::Connection do
  describe "associations" do
    it { is_expected.to belong_to(:attribute_mapper).dependent(:destroy) }
    it { is_expected.to belong_to(:installation) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:hired_workflow_state) }
  end

  describe "#connected?" do
    it "returns true when the api_key and secret are set" do
      jobvite_connection = described_class.new(api_key: "a", secret: "b")

      expect(jobvite_connection).to be_connected
    end

    it "returns false when the api_key or secret is missing" do
      expect(described_class.new).not_to be_connected
      expect(described_class.new(api_key: "a")).not_to be_connected
      expect(described_class.new(secret: "b")).not_to be_connected
    end
  end

  describe "#sync" do
    it "uses the importer" do
      user = create(:user)
      installation = user.installation
      jobvite_connection = create(
        :jobvite_connection,
        installation: installation
      )
      candidate = double("candidate")
      failure = double("failed_candidate_import", success?: false)
      success = double("successful_candidate_import", success?: true)
      results_hash = [{ result: success, candidate: candidate },
                      { result: failure, candidate: candidate }]
      importer = double("importer", import: results_hash)
      allow(Importer).to receive(:new).and_return(importer)

      results = jobvite_connection.sync

      expect(importer).to have_received(:import)
      expect(results[0]).to be_success
      expect(results[1]).not_to be_success
    end
  end

  describe "#attribute_mapper" do
    it "builds and saves an attribute mapper" do
      connection = build(:jobvite_connection)

      connection.save!

      expect(connection.attribute_mapper).to be_an_instance_of(AttributeMapper)
      expect(connection.attribute_mapper).to be_persisted
      expect(mapped_fields_for(connection.attribute_mapper)).
        to match_array([
          %w(first_name first_name),
          %w(last_name last_name),
          %w(email email),
          %w(personal_email personal_email),
          %w(start_date start_date),
          %w(gender gender),
        ])
    end
  end

  def mapped_fields_for(attribute_mapper)
    attribute_mapper.field_mappings.map do |field_mapping|
      [field_mapping.integration_field_id, field_mapping.namely_field_name]
    end
  end
end
