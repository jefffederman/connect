require "rails_helper"

def mapped_fields
  {
    first_name: "firstName",
    last_name: "lastName",
    email: "email",
    gender: "gender",
    phone: "home_phone",
    # TODO: Subsidiary
    # TODO: title
  }
end

describe NetSuite::AttributeMapperBuilder do
  describe "AttributeMapper" do
    it "returns an AttributeMapper" do
      builder = NetSuite::AttributeMapperBuilder.new(user: create(:user))

      builder.build

      expect(builder.attribute_mapper).to be_an_instance_of(AttributeMapper)
    end

    it "persists the AttributeMapper" do
      builder = NetSuite::AttributeMapperBuilder.new(user: create(:user))

      builder.build

      expect(builder.attribute_mapper).to be_persisted
    end
  end

  describe "#field_mappings" do
    mapped_fields.keys.each do |field|
      it "has a FieldMapping for #{field}"
    end
  end
end

