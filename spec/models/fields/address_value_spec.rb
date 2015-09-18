require "rails_helper"

describe Fields::AddressValue do
  describe "#to_s" do
    it "returns the original value as a string" do
      value = Fields::AddressValue.new(
        "address1" => "123 Main Street",
        "address2" => "Suite 501",
        "city" => "Boston",
        "state_id" => "MA",
        "zip" => "11213",
        "country_id" => "US"
      )

      result = value.to_s

      expect(result).to eq(<<-ADDRESS.strip_heredoc.strip)
        123 Main Street
        Suite 501
        Boston, MA 11213
        US
      ADDRESS
    end
  end

  describe "#to_raw" do
    it "returns the original value" do
      expect(Fields::AddressValue.new(5).to_raw).to eq(5)
    end
  end

  describe "#to_date" do
    it "returns nil" do
      expect(Fields::AddressValue.new("08/26/1986").to_date).
        to be_nil
    end
  end

  describe "#to_address" do
    context "with a valid address" do
      it "returns an address object" do
        value = Fields::AddressValue.new(
          "address1" => "123 Main Street",
          "address2" => "Suite 501",
          "city" => "Boston",
          "state_id" => "MA",
          "zip" => "11213",
          "country_id" => "US"
        )

        result = value.to_address

        expect(result.street1).to eq("123 Main Street")
        expect(result.street2).to eq("Suite 501")
        expect(result.city).to eq("Boston")
        expect(result.state).to eq("MA")
        expect(result.zip).to eq("11213")
        expect(result.country).to eq("US")
      end
    end

    context "with an address missing fields" do
      it "returns nil" do
        value = Fields::AddressValue.new(
          "address1" => "123 Main Street",
          "address2" => "Suite 501",
          "city" => nil,
          "state_id" => "MA",
          "zip" => "11213",
          "country_id" => "US"
        )

        result = value.to_address

        expect(result).to be_nil
      end
    end
  end
end
