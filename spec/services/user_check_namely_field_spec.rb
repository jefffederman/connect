require "spec_helper"
require_relative "../../app/services/user_check_namely_field"

describe UserCheckNamelyField do
  describe "#missing_namely_field?" do
    context "connected and defined but not previously found" do
      it "returns false and updates the found namely field" do
        connection = stub_connection(
          fields: %w(field_name),
          found: false,
          required_field: :field_name
        )

        result = check(connection).missing_namely_field?

        expect(result).to eq(false)
        expect(connection).to have_received(:update).
          with(found_namely_field: true)
      end
    end

    context "previously found" do
      it "returns false without updating" do
        connection = stub_connection(
          fields: %w(field_name),
          found: true,
          required_field: :field_name
        )

        result = check(connection).missing_namely_field?

        expect(result).to eq(false)
        expect(connection).not_to have_received(:update)
      end
    end

    context "disconnected" do
      it "returns true" do
        connection = double(:connection, connected?: false)

        result = check(connection).missing_namely_field?

        expect(result).to eq(true)
      end
    end

    context "connected and undefined" do
      it "returns true" do
        connection = stub_connection(
          fields: %w(other_field_name),
          found: false,
          required_field: :expected_field_name
        )

        result = check(connection).missing_namely_field?

        expect(result).to eq(true)
        expect(connection).not_to have_received(:update)
      end
    end
  end

  def stub_connection(found:, fields:, required_field:)
    double(
      :connection,
      connected?: true,
      found_namely_field?: found,
      required_namely_field: required_field,
      update: true,
      installation: stub_installation(fields)
    )
  end

  def stub_installation(fields)
    double(:installation, namely_connection: stub_namely_connection(fields))
  end

  def stub_namely_connection(fields)
    double(:namely_connection, fields: stub_fields_named(fields))
  end

  def stub_fields_named(names)
    fields = names.map do |name|
      double(:field, name: name)
    end

    double(:fields, all: fields)
  end

  def check(connection)
    UserCheckNamelyField.new(connection)
  end
end
