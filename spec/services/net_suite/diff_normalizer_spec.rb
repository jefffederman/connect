require "rails_helper"

describe NetSuite::DiffNormalizer do
  describe "::normalize" do
    let(:profile) do 
      build(:namely_profile,
        home: {
          address1: "14 Happy Pl",
          address2: "222",
          city: "Brooklyn",
          state_id: "NY",
          zip: "11222",
          country_id: "US"
        })
    end
    let(:configuration) { double(:config, subsidiary_id: 222) }
    let(:attribute_mapper) { create(:attribute_mapper) }

    before do
      FactoryGirl.create(:field_mapping,
        attribute_mapper: attribute_mapper,
        integration_field_id: "address",
        namely_field_name: "home")
    end

    it "returns a normalized hash" do
      profile["home"] = Fields::AddressValue.new(profile["home"])
      employee = NetSuite::Normalizer.new(attribute_mapper: attribute_mapper, configuration: configuration).export(profile)

      result = NetSuite::DiffNormalizer.normalize(employee)
      expect(result["defaultAddress"]).to eq("14 Happy Pl<br>222<br>Brooklyn NY 11222<br>United States") 
    end
  end
end
