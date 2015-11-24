require "rails_helper"

describe NetSuite::Matcher do
  let(:attribute_mapper) { create(:attribute_mapper) }

  before do
    FactoryGirl.create(:field_mapping,
      attribute_mapper: attribute_mapper,
      integration_field_id: "firstName",
      namely_field_name: "first_name")
    FactoryGirl.create(:field_mapping,
      attribute_mapper: attribute_mapper,
      integration_field_id: "lastName",
      namely_field_name: "last_name")
    FactoryGirl.create(:field_mapping,
      attribute_mapper: attribute_mapper,
      integration_field_id: "email",
      namely_field_name: "email")
  end

  describe "#matched" do
    context "when netsuite_id matches" do
      let(:employee1) do
        {
          "lastName" => "Wonderland",
          "firstName" => "Alex",
          "email" => "alex@example.com",
          "internalId" => "TEST",
        }
      end
      let(:employee2) do
        {
          "lastName" => "Wonderland",
          "firstName" => "Alice",
          "email" => "alice@example.com",
          "internalId" => "TEST2",
        }
      end
      let(:profile1) do
        build(:namely_profile, {
          "last_name" => "Wonderlandee",
          "first_name" => "Alex",
          "email" => "alex@example.com",
          "netsuite_id" => "TEST",
        })
      end
      let(:profile2) do
        build(:namely_profile, {
          "last_name" => "Wonderland",
          "first_name" => "Alice",
          "email" => "test@example.com",
          "netsuite_id" => "TEST5",
        })
      end

      it "returns list of matched objects" do
        matcher = described_class.new(
          mapper: attribute_mapper,
          fields: ["email"],
          profiles: [
            profile1, profile2
          ],
          employees: [
            employee1, employee2
          ],
        )

        results = matcher.results
        expect(results.length).to be(2)
        expect(results.map { |result| {p: result.profile, r: result.matched?} }).to match_array([
          {p: profile1, r: true},
          {p: profile2, r: false}
        ])
      end
    end
    context "when netsuite_id doesn't match" do
      let(:employee1) do
        {
          "lastName" => "Wonderland",
          "firstName" => "Alex",
          "email" => "alex@example.com",
          "internalId" => "TEST",
        }
      end
      let(:employee2) do
        {
          "lastName" => "Wonderland",
          "firstName" => "Alice",
          "email" => "alice@example.com",
          "internalId" => "TEST2",
        }
      end
      let(:employee3) do
        {
          "lastName" => "Wonderland",
          "firstName" => "None",
          "email" => "none@example.com",
          "internalId" => "TEST3",
        }
      end
      let(:profile1) do
        build(:namely_profile, {
          "last_name" => "Wonderlandee",
          "first_name" => "Alex",
          "email" => "alex@example.com",
        })
      end
      let(:profile2) do
        build(:namely_profile, {
          "last_name" => "Wonderland",
          "first_name" => "Alice",
          "email" => "test@example.com",
        })
      end
      let(:profile3) do
        build(:namely_profile, {
          "first_name" => "None",
          "last_name" => "Wonderland",
          "email" => "alice@example.com",
        })
      end
      it "uses one field to match objects" do
        matcher = described_class.new(
          mapper: attribute_mapper,
          fields: ["email"],
          profiles: [
            profile2, profile3
          ],
          employees: [
            employee2, employee3
          ],
        )
        results = matcher.results
        expect(results.length).to be(2)
        expect(results.map { |result| {p: result.profile, r: result.matched?} }).to match_array([
          {p: profile3, r: true},
          {p: profile2, r: false}
        ])
      end
      it "uses the fields list to match objects" do
        matcher = described_class.new(
          mapper: attribute_mapper,
          fields: ["firstName", "lastName"],
          profiles: [
            profile2, profile3, profile1
          ],
          employees: [
            employee2, employee3, employee1
          ],
        )
        results = matcher.results
        expect(results.length).to be(3)
        expect(results.map { |result| {p: result.profile, r: result.matched?} }).to match_array([
          {p: profile1, r: false},
          {p: profile2, r: true},
          {p: profile3, r: true}
        ])
      end
    end
  end
end



