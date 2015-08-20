require "rails_helper"

describe TypeForField do
  describe ".for_field" do
    it "reports 'boolean' for field that came in with boolean values" do
      fields = [
        described_class.for_field(name: "foo", value: false),
        described_class.for_field(name: "foo", value: true)
      ]

      expect(fields).to match_array(["boolean", "boolean"])
    end

    it "reports 'date' for fixnums on date fields" do
      field = described_class.for_field(
        name: "hireDate",
        value: 1234567890
      )

      expect(field).to eq("date")
      expect(field).not_to eq("fixnum")
    end

    it "reports 'email' for strings with an appropriate field name" do
      field = described_class.for_field(
        name: "email",
        value: "test@example.com"
      )

      expect(field).to eq("email")
    end

    it "reports 'fixnum' for fixnums" do
      field = described_class.for_field(name: "foo", value: 1234)

      expect(field).to eq("fixnum")
      expect(field).not_to eq("date")
    end

    it "reports 'object' for hashes" do
      field = described_class.for_field(name: "bar", value: {})

      expect(field).to eq("object")
    end

    it "reports 'text' for strings" do
      field = described_class.for_field(name: "foo", value: "Bar")

      expect(field).to eq("text")
    end
  end
end
