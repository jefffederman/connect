require "rails_helper"

def mapped_fields
  {
    "email" =>  "email",
    "first_name" => "firstName",
    "gender" =>  "gender",
    "home_phone" =>  "phone",
    "last_name" =>  "lastName",
    # TODO: Subsidiary
    # TODO: title
  }
end

def new_attribute_mapper_builder
  NetSuite::AttributeMapperBuilder.new(user: create(:user))
end

describe NetSuite::AttributeMapperBuilder do
  describe "AttributeMapper" do
    it "returns an AttributeMapper" do
      builder = new_attribute_mapper_builder

      builder.build

      expect(builder.attribute_mapper).to be_an_instance_of(AttributeMapper)
    end

    it "persists the AttributeMapper" do
      builder = new_attribute_mapper_builder

      builder.build

      expect(builder.attribute_mapper).to be_persisted
    end
  end

  describe "#field_mappings" do
    it "has a FieldMapping for each default field" do
      builder = new_attribute_mapper_builder
      builder.build

      integration_mappings = builder.field_mappings.map(
        &:integration_field_name
      )
      namely_mappings = builder.field_mappings.map(
        &:namely_field_name
      )

      expect(integration_mappings).to match_array(mapped_fields.values)
      expect(namely_mappings).to match_array(mapped_fields.keys)
    end

    it "persists the FieldMappings" do
      builder = new_attribute_mapper_builder
      builder.build

      expect(
        builder.attribute_mapper.field_mappings.reject(&:persisted?)
      ).to be_empty
    end
  end
end
