require "rails_helper"

describe Icims::Candidate do
  describe "#start_date" do
    before { Timecop.freeze }
    after { Timecop.return }

    it "returns the start date in ISO8601 format" do
      candidate = described_class.new(
        "startdate" => Date.today.strftime("%Y-%m-%d")
      )

      expect(candidate.start_date).to eq Date.today.iso8601
    end

    it "returns nil when there is no start date" do
      candidate = described_class.new(
        "startdate" => nil
      )

      expect(candidate.start_date).to be_nil
    end
  end

  describe "#name" do
    it "returns the full name from candidate information" do
      first_name = "Roger"
      last_name = "Rult"

      candidate = described_class.new(
        "firstname" => first_name,
        "lastname" => last_name
      )

      expect(candidate.name).to eql "#{first_name} #{last_name}"
    end
  end

  describe "#contact_number" do
    context "when just a home number is present" do
      it "returns the number" do
        candidate = described_class.new("phones" => phone_numbers)
        expect(candidate.contact_number).to eq "888-888-8888"
      end
    end

    context "when no numbers are present" do
      it "returns nothing" do
        candidate = described_class.new({})
        expect(candidate.contact_number).to be_nil
      end
    end

    def phone_numbers
      [
        {
          "phonetype" => {
            "value" => "Home",
          },
          "phonenumber" => "888-888-8888",
        },
        {
          "phonetype" => {
            "value" => "Work",
          },
          "phonenumber" => "302-555-5555",
        },
      ]
    end
  end

  describe "#home_address" do
    it "there are no addresses" do
      candidate = described_class.new({})
      expect(candidate.home_address).to be_nil
    end

    it "doesn't return anything without a home address" do
      candidate = described_class.new(
        "addresses" => [
          {
            "addresstype" => {
              "value" => "Not Home",
            },
          },
        ]
      )
      expect(candidate.home_address).to be_nil
    end

    it "returns a formatted list of the given address" do
      candidate = described_class.new(
        "addresses" => [
          {
            "addresstype" => {
              "value" => "Home",
            },
            "addressstreet1" => "123 address",
            "addressstreet2" => "PO Box",
            "addresscity" => "New York",
            "addresszip" => "10001",
            "addresscountry" => {
              "abbrev" => "US",
            },
            "addressstate" => {
              "abbrev" => "NY",
            },
          },
        ]
      )

      expect(candidate.home_address).not_to be_nil
      expect(candidate.home_address).to eq(
        address1: "123 address",
        address2: "PO Box",
        city: "New York",
        country_id: "US",
        state_id: "NY",
        zip: "10001",
      )
    end
  end
end
