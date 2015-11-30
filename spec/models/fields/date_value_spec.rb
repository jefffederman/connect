require "rails_helper"

describe Fields::DateValue do
  describe "#to_raw" do
    it "returns the original value" do
      expect(Fields::DateValue.new(5).to_raw).to eq(5)
    end
  end

  describe "#to_s" do
    it "returns the original value as a string" do
      expect(Fields::DateValue.new(5).to_s).to eq("5")
    end
  end

  describe "#to_date" do
    it "parses a Namely date string" do
      expect(Fields::DateValue.new("1986-08-26").to_date).
        to eq(Date.new(1986, 8, 26))
    end

    it "is nil for empty string values" do
      expect(Fields::DateValue.new("").to_date).to be nil
    end

    it "is nil for things that don't parse to a date" do
      expect(Fields::DateValue.new("foo").to_date).to be nil
    end
  end

  describe "#to_address" do
    it "returns nil" do
      expect(Fields::DateValue.new("").to_address).to be_nil
    end
  end
end
