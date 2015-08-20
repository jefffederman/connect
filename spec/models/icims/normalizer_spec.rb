require "rails_helper"

describe Icims::Normalizer do
  describe "#call" do
    it "transforms a iCIMS candidate into a Hash appropriate for the Namely API" do
      mapper = described_class.new
      icims_candidate = double(
        "icims_candidate",
        id: "edO1Ggwt",
        email: "crash.override@example.com",
        firstname: "Dade",
        lastname: "Murphy",
        start_date: "2014-01-02",
        gender: "Opt Out",
        home_address: "my home",
      )

      expect(mapper.call(icims_candidate)).to eq(
        first_name: "Dade",
        last_name: "Murphy",
        email: "crash.override@example.com",
        user_status: "active",
        start_date: "2014-01-02",
        home: "my home",
        icims_id: "edO1Ggwt",
      )
    end

    it "maps genders correctly" do
      mapper = described_class.new
      expected_mapping = {
        "Male" => "Male",
        "Female" => "Female",
        "Declined to Self Identify" => nil,
        "Undefined" => nil,
        "UNEXPECTED VALUE" => nil,
      }

      expected_mapping.each do |icims_gender, namely_gender|
        icims_candidate = double(
          "icims_candidate",
          id: "edO1Ggwt",
          firstname: "Sam",
          lastname: "Smith",
          email: "user@example.com",
          salary: nil,
          home_address: nil,
          start_date: Date.today.iso8601,
          gender: icims_gender,
        )

        result = mapper.call(icims_candidate)

        expect(result[:gender]).to eq namely_gender
      end
    end

    it "doesn't include a start date if iCIMS didn't provide one" do
      mapper = described_class.new
      icims_candidate = double(
        "icims_candidate",
        id: "edO1Ggwt",
        firstname: "Kate",
        lastname: "Libby",
        email: "acid.burn@example.com",
        start_date: nil,
        salary: nil,
        home_address: nil,
        gender: "Female",
      )

      result = mapper.call(icims_candidate)

      expect(result).not_to have_key(:start_date)
    end
  end

  describe "#namely_identifier_field" do
    it "returns the custom Namely profile field that stores the iCIMS ID" do
      mapper = described_class.new

      expect(mapper.namely_identifier_field).to eq :icims_id
    end
  end

  describe "#identifier" do
    it "returns the iCIMS ID of a given candidate" do
      icims_candidate = double("icims_candidate", id: "MY_UNIQUE_ID")
      mapper = described_class.new

      expect(mapper.identifier(icims_candidate)).to eq "MY_UNIQUE_ID"
    end
  end

  describe "#readable_name" do
    it "returns a human-readable representation of the candidate" do
      icims_candidate = double(
        "icims_candidate",
        name: "Kate Libby",
        id: "MY_UNIQUE_ID",
      )
      mapper = described_class.new

      expect(mapper.readable_name(icims_candidate)).
        to eq "Kate Libby (MY_UNIQUE_ID)"
    end
  end
end
