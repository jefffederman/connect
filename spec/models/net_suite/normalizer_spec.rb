require "rails_helper"

describe NetSuite::Normalizer do
  let(:configuration) { double("configuration", subsidiary_id: "123") }

  describe "delegation" do
    subject { build_normalizer }
    it { should delegate_method(:field_mappings).to(:attribute_mapper) }
    it { should delegate_method(:mapping_direction).to(:attribute_mapper) }
  end

  describe "#export" do
    it "returns a converted data structure based on field mappings" do
      export_attributes = export

      expect(export_attributes.keys).to include(*%w(
        email
        firstName
        gender
        lastName
        phone
      ))
    end

    it "doesn't map empty values" do
      delete_keys = ["email", "last_name"]
      profile_data = stubbed_profile_data
      delete_keys.each { |key| profile_data[key] = nil }

      export_attributes = export(profile_data)

      expect(export_attributes).not_to have_key("email")
      expect(export_attributes).not_to have_key("lastName")
    end

    describe "value handling" do
      it "sets expected values in the profile for regular attributes" do
        attributes = {
          "email" => "test@example.com",
          "first_name" => "First",
          "home_phone" => "919-555-1212",
          "last_name" => "Last",
        }

        profile_data = stubbed_profile_data.merge(attributes)

        export_attributes = export(profile_data)

        expect(export_attributes["email"]).to eq(attributes["email"])
        expect(export_attributes["firstName"]).to eq(attributes["first_name"])
        expect(export_attributes["phone"]).to eq(attributes["home_phone"])
        expect(export_attributes["lastName"]).to eq(attributes["last_name"])
      end
    end

    context "gender mapping" do
      it "maps 'Female to _female'" do
        profile_data = stubbed_profile_data.merge("gender" => "Female")

        export_attributes = export(profile_data)

        expect(export_attributes["gender"]).to eq("_female")
      end

      it "maps 'Male to _male'" do
        profile_data = stubbed_profile_data.merge("gender" => "Male")

        export_attributes = export(profile_data)

        expect(export_attributes["gender"]).to eq("_male")
      end

      it "maps nil to '_omitted'" do
        profile_data = stubbed_profile_data.merge("gender" => nil)

        export_attributes = export(profile_data)

        expect(export_attributes["gender"]).to eq("_omitted")
      end

      it "maps an empty string to '_omitted'" do
        profile_data = stubbed_profile_data.merge("gender" => "")

        export_attributes = export(profile_data)

        expect(export_attributes["gender"]).to eq("_omitted")
      end
    end

    context "subsidiary_id" do
      it "provides a subsidiary_id from the configuration" do
        export_attributes = export

        expect(
          export_attributes["subsidiary"]
        ).to eq("internalId" => configuration.subsidiary_id)
      end
    end

    context "custom fields" do
      it "generates a custom field list" do
        profile_data = stubbed_profile_data.merge(
          "facebook" => "http://example.com/facebook",
          "linkedin" => "http://example.com/linkedin",
        )
        attribute_mapper = build_attribute_mapper
        attribute_mapper.field_mappings.map!(
          "custom:1234:linkedin_url",
          to: "linkedin",
          name: "LinkedIn URL"
        )
        attribute_mapper.field_mappings.map!(
          "custom:5678:facebook_url",
          to: "facebook",
          name: "Facebook URL"
        )
        normalizer = build_normalizer(attribute_mapper: attribute_mapper)

        export_attributes = export(profile_data, normalizer: normalizer)

        expect(export_attributes["customFieldList"]).to include(
          "customField" => include(
            {
              "internalId" => "1234",
              "scriptId" => "linkedin_url",
              "value" => "http://example.com/linkedin"
            },
            {
              "internalId" => "5678",
              "scriptId" => "facebook_url",
              "value" => "http://example.com/facebook"
            }
          )
        )
        expect(export_attributes.keys.grep(/custom:/)).to be_empty
      end
    end
  end

  def build_normalizer(attribute_mapper: build_attribute_mapper)
    NetSuite::Normalizer.new(
      attribute_mapper: attribute_mapper,
      configuration: configuration
    )
  end

  def build_attribute_mapper
    employee_json =
      File.read("spec/fixtures/api_responses/net_suite_employee.json")
    stub_request(:get, %r{.*/employees\?pageSize=.*}).
      to_return(status: 200, body: employee_json)
    create(:net_suite_connection).attribute_mapper
  end

  def export(profile_data = stubbed_profile_data, normalizer: build_normalizer)
    normalizer.export(stubbed_profile(profile_data))
  end

  def stubbed_profile_data
    {
      "email" => "test@example.com",
      "first_name" => "First",
      "gender" => "Female",
      "home_phone" => "212-555-1212",
      "last_name" => "Last"
    }
  end

  def stubbed_profile(data = stubbed_profile_data)
    Profile.new(data)
  end
end
