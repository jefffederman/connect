require "rails_helper"

describe FieldMapping do
  describe "validations" do
    it { should validate_presence_of(:integration_field_name) }
    it { should validate_presence_of(:attribute_mapper) }
  end

  describe "associations" do
    it { should belong_to(:attribute_mapper) }
  end

  describe "#integration_key" do
    context "spaces" do
      it "underscores" do
        expect(integration_key(field_name: "integration field name")).
          to eq("integration_field_name")
      end
    end

    context "camelCase" do
      it "underscores" do
        expect(integration_key(field_name: "integrationFieldName")).
          to eq("integration_field_name")
      end
    end

    context "dash-case" do
      it "underscores" do
        expect(integration_key(field_name: "integration-field-name")).
          to eq("integration_field_name")
      end
    end
  end

  describe ".map!" do
    context "for an existing field" do
      it "leaves the existing field" do
        attribute_mapper = create(:attribute_mapper)
        create(
          :field_mapping,
          attribute_mapper: attribute_mapper,
          integration_field_id: "integration",
          namely_field_name: "mapped"
        )

        attribute_mapper.field_mappings.map!("integration")

        result = FieldMapping.last
        expect(result.integration_field_id).to eq("integration")
        expect(result.namely_field_name).to eq("mapped")
      end
    end

    context "for a new field" do
      it "creates the field" do
        attribute_mapper = create(:attribute_mapper)

        attribute_mapper.field_mappings.map!(
          "integration",
          to: "namely",
          name: "Name",
        )

        result = FieldMapping.last
        expect(result.integration_field_id).to eq("integration")
        expect(result.integration_field_name).to eq("Name")
        expect(result.namely_field_name).to eq("namely")
      end
    end
  end

  describe ".each_with_namely_field" do
    it "yields each mapped field and returns the resulting hash" do
      map_fields(
        "firstName" => "first_name",
        "lastName" => "last_name",
        "url" => nil,
      ).each(&:save!)
      data = {
        "firstName" => "First",
        "lastName" => "Last",
        "unknown" => "Unknown",
        "url" => "http://example.com",
      }

      result = FieldMapping.each_with_namely_field do |mapping, accumulator|
        value = data[mapping.integration_field_name]
        accumulator[mapping.namely_field_name] = value
      end

      expect(result).to eq("first_name" => "First", "last_name" => "Last")
    end
  end

  def integration_key(field_name:)
    FieldMapping.new(integration_field_name: field_name).integration_key
  end

  def map_fields(fields)
    fields.map do |integration_field_name, namely_field_name|
      build(
        :field_mapping,
        namely_field_name: namely_field_name,
        integration_field_name: integration_field_name
      )
    end
  end
end
