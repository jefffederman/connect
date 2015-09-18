require "rails_helper"

describe Fields::RecordValue do
  describe "#to_s" do
    it "finds the value of the first, non-id key" do
      expect(Fields::RecordValue.new("id" => "x", "title" => "expected").to_s).
        to eq("expected")
    end
  end

  describe "#to_raw" do
    it "returns the original value" do
      expect(Fields::RecordValue.new(5).to_raw).to eq(5)
    end
  end

  describe "#to_date" do
    it "returns nil" do
      expect(Fields::RecordValue.new("08/26/1986").to_date).
        to be_nil
    end
  end

  describe "#to_address" do
    it "returns nil" do
      expect(Fields::RecordValue.new("").to_address).to be_nil
    end
  end
end
