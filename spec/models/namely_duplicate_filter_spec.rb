require "rails_helper"

describe NamelyDuplicateFilter do
  describe "#filter" do
    it "returns only the records that haven't already been imported to Namely" do
      person_b = double("third_party_record", person_id: "B2")
      person_c = double("third_party_record", person_id: "C3")
      person_d = double("third_party_record", person_id: "D4")
      unfiltered = [person_b, person_c, person_d]
      profiles = double("profiles", all: [
        double("profile", external_service_id: "A1"),
        double("profile", external_service_id: "B2"),
        double("profile", external_service_id: "D4"),
      ])
      namely_connection = double("namely_connection", profiles: profiles)
      normalizer = double(
        "normalizer",
        namely_identifier_field: :external_service_id,
      )
      allow(normalizer).to receive(:identifier) do |third_party_record|
        third_party_record.person_id
      end
      filter = described_class.new(
        namely_connection: namely_connection,
        normalizer: normalizer,
      )

      uniques = filter.filter(unfiltered)

      expect(uniques).to eq [person_c]
    end
  end
end
