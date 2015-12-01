require "rails_helper"

describe Fields::Collection do
  describe "#new" do
    %w(email longtext referenceselect select text).each do |type|
      context "for a #{type} field" do
        it "returns a string value" do
          result = export(type: type, value: "expected value")

          expect(result).to be_a(Fields::StringValue)
          expect(result.to_raw).to eq("expected value")
        end
      end
    end

    context "for a referencehistory field" do
      it "returns a record value" do
        result = export(
          type: "referencehistory",
          value: { id: "expected value" }
        )

        expect(result).to be_a(Fields::RecordValue)
        expect(result.to_raw).to eq(id: "expected value")
      end
    end

    describe "for a date value" do
      it "parses into a date object" do
        result = export(type: "date", value: "1986-08-26")

        expect(result.to_date).to eq(Date.new(1986, 8, 26))
      end
    end

    describe "for an address field" do
      it "parses into an address object" do
        address = { address1: "123 Main Street" }
        result = export(type: "address", value: address)

        expect(result).to be_a(Fields::AddressValue)
        expect(result.to_raw).to eq(address)
      end
    end

    context "for a nil value" do
      it "returns nil" do
        result = export(type: "text", value: nil)

        expect(result).to be_nil
      end
    end

    context "for an unknown field" do
      it "returns nil" do
        namely_connection = stub_connection_with_field(
          name: "example",
          type: "text"
        )
        collection = Fields::Collection.new(namely_connection)
        profile = { "unknown" => "value" }

        result = collection.export("unknown", from: profile)

        expect(result).to be_nil
      end
    end
  end

  def export(type:, value:)
    namely_connection = stub_connection_with_field(
      name: "example",
      type: type,
    )
    collection = Fields::Collection.new(namely_connection)
    profile = { "example" => value }

    collection.export("example", from: profile)
  end

  def stub_connection_with_field(name:, type:)
    double(:namely_connection).tap do |namely_connection|
      all_fields = [double(:field, type: type, name: name)]
      fields = double(:fields, all: all_fields)
      allow(namely_connection).to receive(:fields).and_return(fields)
    end
  end
end
