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

      expect(export_attributes.keys).to match_array(%w(
        customFieldList
        email
        firstName
        gender
        isInactive
        lastName
        phone
        subsidiary
        releaseDate
        nullFieldList
      ))
    end

    it "does not include custom fields in field mappings if opted out" do
      ClimateControl.modify(NET_SUITE_CUSTOM_FIELDS_ENABLED: "false") do
        export_attributes = export

        expect(export_attributes.keys).not_to include("customFieldList")
      end
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
      it "sets expected values in the profile for string attributes" do
        attributes = {
          "email" => "test@example.com",
          "first_name" => "First",
          "home_phone" => "919-555-1212",
          "last_name" => "Last",
        }

        profile_data = stubbed_profile_data(attributes)

        export_attributes = export(profile_data)

        expect(export_attributes["email"]).to eq(attributes["email"])
        expect(export_attributes["firstName"]).to eq(attributes["first_name"])
        expect(export_attributes["phone"]).to eq(attributes["home_phone"])
        expect(export_attributes["lastName"]).to eq(attributes["last_name"])
      end
    end

    context "gender mapping" do
      it "maps 'Female to _female'" do
        profile_data = stubbed_profile_data("gender" => "Female")

        export_attributes = export(profile_data)

        expect(export_attributes["gender"]).to eq("_female")
      end

      it "maps 'Male to _male'" do
        profile_data = stubbed_profile_data("gender" => "Male")

        export_attributes = export(profile_data)

        expect(export_attributes["gender"]).to eq("_male")
      end

      it "maps nil to '_omitted'" do
        profile_data = stubbed_profile_data("gender" => nil)

        export_attributes = export(profile_data)

        expect(export_attributes["gender"]).to eq("_omitted")
      end

      it "maps an empty string to '_omitted'" do
        profile_data = stubbed_profile_data("gender" => "")

        export_attributes = export(profile_data)

        expect(export_attributes["gender"]).to eq("_omitted")
      end
    end

    context "isInactive" do
      it "maps a user status of 'inactive' to true" do
        profile_data = stubbed_profile_data("user_status" => "inactive")

        export_attributes = export(profile_data)

        expect(export_attributes["isInactive"]).to be true
      end

      it "maps user_status of 'active' values to false" do
        profile_data = stubbed_profile_data("user_status" => "active")

        export_attributes = export(profile_data)

        expect(export_attributes["isInactive"]).to be false
      end
    end

    context "address" do
      it "maps to a NetSuite address hash" do
        profile_data = stubbed_profile_data(
          "first_name" => "Iggy",
          "last_name" => "Igloo"
        ).merge(
          "home" => Fields::AddressValue.new(
            "address1" => "123 Main Street",
            "address2" => "Suite 501",
            "city" => "Boston",
            "state_id" => "MA",
            "zip" => "11213",
            "country_id" => "US"
          )
        )

        export_attributes = export(profile_data)

        expect(export_attributes["addressbookList"]).to eq(
          "addressbook" => [
            {
              "defaultShipping" => true,
              "addressbookAddress" => {
                "zip" => "11213",
                "country" => {
                  "value" => "_unitedStates"
                },
                "addr2" => "Suite 501",
                "addr1" => "123 Main Street",
                "city" => "Boston",
                "addr3" => "",
                "addressee" => "Iggy Igloo",
                "attention" => "",
                "state" => "MA"
              }
            }
          ],
          "replaceAll" => true
        )
      end

      it "removes a missing address" do
        profile_data = stubbed_profile_data.merge("home" => nil)

        export_attributes = export(profile_data)

        expect(export_attributes).not_to have_key("addressbookList")
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

    context "releaseDate" do
      it "maps departure date string to milliseconds since epoch" do
        date = Date.today
        date_string = date.strftime("%m/%d/%Y")
        profile_data = stubbed_profile_data.merge(
          "departure_date" => Fields::DateValue.new(date_string)
        )

        export_attributes = export(profile_data)

        expect(export_attributes["releaseDate"]).to eq(
          date.to_datetime.to_i * 1000
        )
      end
    end

    context "custom fields" do
      it "generates a custom field list" do
        profile_data = stubbed_profile_data(
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

    context "null scalar fields" do
      it "moves keys with null scalar values to the nullFieldList" do
        profile_data = stubbed_profile_data.merge(
          "departure_date" => Fields::DateValue.new(nil)
        )

        export_attributes = export(profile_data)

        expect(export_attributes.keys).not_to include("releaseDate")
        expect(export_attributes["nullFieldList"]).to match_array([
          "releaseDate"
        ])
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

  def stubbed_profile_data(overrides = {})
    stub_string_values(
      {
        "email" => "test@example.com",
        "first_name" => "First",
        "gender" => "Female",
        "home_phone" => "212-555-1212",
        "last_name" => "Last",
      }.merge(overrides)
    ).merge("departure_date" => Fields::DateValue.new("01/01/2016"))
  end

  def stub_string_values(values)
    values.each_with_object({}) do |(name, value), result|
      result[name] = Fields::StringValue.new(value)
    end
  end

  def stubbed_profile(data)
    data
  end
end
