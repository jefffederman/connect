require "rails_helper"

describe Fields::StringValue do
  describe "#to_s" do
    it "returns the original value as a string" do
      expect(Fields::StringValue.new(1).to_s).to eq("1")
    end
  end

  describe "#to_raw" do
    it "returns the original value" do
      expect(Fields::StringValue.new(5).to_raw).to eq(5)
    end
  end

  describe "#to_date" do
    it "returns nil" do
      expect(Fields::StringValue.new("08/26/1986").to_date).
        to be_nil
    end
  end

  describe "#to_address" do
    it "returns nil" do
      expect(Fields::StringValue.new("").to_address).to be_nil
    end
  end
end
