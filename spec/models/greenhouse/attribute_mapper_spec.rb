require 'rails_helper'

describe Greenhouse::AttributeMapper do
  let(:namely_fields) do
    raw_objects = JSON.parse(
      File.read("spec/fixtures/api_responses/fields_with_greenhouse.json")
    )
    raw_objects.fetch("fields").map do |object|
      Namely::Model.new(nil, object)
    end
  end

  subject(:mapper) { described_class.new(namely_fields) }
  describe "#call" do
    it "transforms a Greenhouse candidate into a Hash appropriate for the Namely API" do
      greenhouse_candidate = JSON.parse(
        File.read("spec/fixtures/api_requests/greenhouse_payload.json"))["payload"]

      expect(mapper.call(greenhouse_candidate)).to eq(
        first_name: "Johnny",
        last_name: "Smith",
        email: "personal@example.com",
        user_status: "active",
        start_date: "2015-01-23",
        home: { address1: "455 Broadway New York, NY 10280" },
        greenhouse_id: "20",
        salary: { yearly_amount: 80000, currency_type: "USD", date: "2015-01-23"},
      )
    end

    context "handle missing none mandatory fields" do
      it "return default values when not present in payload" do
        greenhouse_candidate = JSON.parse(
          File.read("spec/fixtures/api_requests/greenhouse_payload_missing.json")
        )["payload"]

        expect(mapper.call(greenhouse_candidate)).to eq(
          first_name: "Johnny",
          last_name: "Smith",
          email: "personal@example.com",
          user_status: "active",
          greenhouse_id: "20",
          home: { address1: "" }
        )
      end

      it "return default values for address if nil" do
        greenhouse_candidate = {"application" => {
          "candidate" => {
            "first_name" => "Johnny",
            "last_name" => "Smith",
            "email_addresses" => [
              {
                "type" => "personal",
                "value" => "personal@example.com"
              }
            ],
            "addresses" => nil
          }, "id" => "greenhouse_id"}}

        expect(mapper.call(greenhouse_candidate)).to eq(
          first_name: "Johnny",
          last_name: "Smith",
          email: "personal@example.com",
          user_status: "active",
          greenhouse_id: "greenhouse_id",
        )
      end

      it "return default blank for email if nil" do
        greenhouse_candidate = {'application' => {
          "candidate" => {
            "first_name" => "Johnny",
            "last_name" => "Smith",
            "email_addresses" => nil,
            "addresses" => nil
          }, "id" => "greenhouse_id"}}

        expect(mapper.call(greenhouse_candidate)).to eq(
          first_name: "Johnny",
          last_name: "Smith",
          user_status: "active",
          greenhouse_id: "greenhouse_id",
        )
      end
    end
  end

  describe "#namely_identifier_field" do
    it "returns the custom Namely profile field that stores the Greenhouse ID" do
      expect(mapper.namely_identifier_field).to eq :greenhouse_id
    end
  end
end
