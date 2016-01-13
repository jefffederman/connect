require "rails_helper"

describe AttributeMapper do
  describe "associations" do
    it { expect have_many(:field_mappings).dependent(:destroy) }
  end

  describe "#import" do
    it "maps field names" do
      field_mappings = map_fields(
        "firstName" => "first_name",
        "lastName" => "last_name",
        "birthDate" => "birth_date",
        "url" => nil,
      )
      attribute_mapper = create(
        :attribute_mapper,
        field_mappings: field_mappings
      )

      result = attribute_mapper.import(
        firstName: "First",
        lastName: "Last",
        birthDate: nil,
        unknown: "Unknown",
        url: "http://example.com"
      )

      expect(result).to eq(
        first_name: "First",
        last_name: "Last"
      )
    end
  end

  def map_fields(fields)
    fields.map do |integration_field_name, namely_field_name|
      create(
        :field_mapping,
        namely_field_name: namely_field_name,
        integration_field_id: integration_field_name,
        integration_field_name: integration_field_name
      )
    end
  end
end
