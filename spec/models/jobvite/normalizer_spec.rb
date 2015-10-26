require "rails_helper"

describe Jobvite::Normalizer do
  describe "#call" do
    it "provides the attribute mapper with a normalized profile hash" do
      attribute_mapper = stub_attribute_mapper
      mapper = described_class.new(attribute_mapper: attribute_mapper)
      jobvite_candidate = double(
        "jobvite_candidate",
        e_id: "edO1Ggwt",
        email: "crash.override@example.com",
        first_name: "Dade",
        last_name: "Murphy",
        start_date: "2014-01-02",
        gender: "Undefined",
      )

      mapper.call(jobvite_candidate)

      expect(attribute_mapper).
        to have_imported(
          first_name: "Dade",
          last_name: "Murphy",
          email: "crash.override@example.com",
          personal_email: "crash.override@example.com",
          user_status: "active",
          start_date: "2014-01-02",
          jobvite_id: "edO1Ggwt",
          gender: nil,
        )
    end

    it "maps genders correctly" do
      expected_mapping = {
        "Male" => "Male",
        "Female" => "Female",
        "Declined to Self Identify" => nil,
        "Undefined" => nil,
        "UNEXPECTED VALUE" => nil,
      }

      expected_mapping.each do |jobvite_gender, namely_gender|
        attribute_mapper = stub_attribute_mapper
        mapper = described_class.new(attribute_mapper: attribute_mapper)
        jobvite_candidate = double(
          "jobvite_candidate",
          e_id: "edO1Ggwt",
          first_name: "Sam",
          last_name: "Smith",
          email: "user@example.com",
          start_date: Date.today.iso8601,
          gender: jobvite_gender,
        )

        mapper.call(jobvite_candidate)

        expect(attribute_mapper).
          to have_imported(hash_including(gender: namely_gender))
      end
    end

    it "doesn't include a start date if Jobvite didn't provide one" do
      attribute_mapper = stub_attribute_mapper
      mapper = described_class.new(attribute_mapper: attribute_mapper)
      jobvite_candidate = double(
        "jobvite_candidate",
        e_id: "edO1Ggwt",
        first_name: "Kate",
        last_name: "Libby",
        email: "acid.burn@example.com",
        start_date: nil,
        gender: "Female",
      )

      mapper.call(jobvite_candidate)

      expect(attribute_mapper).
        to have_imported(hash_including(start_date: nil))
    end
  end

  describe "#namely_identifier_field" do
    it "returns the custom Namely profile field that stores the Jobvite ID" do
      attribute_mapper = stub_attribute_mapper
      mapper = described_class.new(attribute_mapper: attribute_mapper)

      expect(mapper.namely_identifier_field).to eq :jobvite_id
    end
  end

  describe "#identifier" do
    it "returns the Jobvite ID of a given candidate" do
      jobvite_candidate = double("jobvite_candidate", e_id: "MY_UNIQUE_ID")
      attribute_mapper = stub_attribute_mapper
      mapper = described_class.new(attribute_mapper: attribute_mapper)

      expect(mapper.identifier(jobvite_candidate)).to eq "MY_UNIQUE_ID"
    end
  end

  describe "#readable_name" do
    it "returns a human-readable representation of the candidate" do
      jobvite_candidate = double(
        "jobvite_candidate",
        first_name: "Kate",
        last_name: "Libby",
        e_id: "MY_UNIQUE_ID",
      )
      attribute_mapper = stub_attribute_mapper
      mapper = described_class.new(attribute_mapper: attribute_mapper)

      expect(mapper.readable_name(jobvite_candidate)).
        to eq "Kate Libby (MY_UNIQUE_ID)"
    end
  end

  def stub_attribute_mapper
    double(:attribute_mapper).tap do |attribute_mapper|
      allow(attribute_mapper).to receive(:import)
    end
  end

  def have_imported(attributes)
    have_received(:import).with(attributes)
  end
end
