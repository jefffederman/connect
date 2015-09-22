require 'rails_helper'

describe Greenhouse::Normalizer do
  let(:namely_fields) do
    raw_objects = JSON.parse(
      File.read("spec/fixtures/api_responses/fields_with_greenhouse.json")
    )
    raw_objects.fetch("fields").map do |object|
      Namely::Model.new(nil, object)
    end
  end

  describe "#call" do
    it "maps a Greenhouse candidate into a Namely profile" do
      expect(map_fixture("greenhouse_payload")).to eq(
        first_name: "Johnny",
        last_name: "Smith",
        personal_email: "personal@example.com",
        email: "work@example.com",
        user_status: "active",
        start_date: "2015-01-23",
        home: { address1: "455 Broadway New York, NY 10280" },
        greenhouse_id: "20",
        salary: {
          yearly_amount: 80000,
          currency_type: "USD",
          date: "2015-01-23"
        },
        favorite_programming_language: "Rails"
      )
    end

    context "when salary field is a short_text" do
      it "maps a Greenhouse candidate into a Namely profile" do
        expect(map_fixture("greenhouse_payload_salary_text")).to eq(
          first_name: "Johnny",
          last_name: "Smith",
          personal_email: "personal@example.com",
          email: "work@example.com",
          user_status: "active",
          start_date: "2015-01-23",
          home: { address1: "455 Broadway New York, NY 10280" },
          greenhouse_id: "20",
          salary: {
            yearly_amount: 70000,
            currency_type: "USD",
            date: "2015-01-23"
          },
        )
      end
    end

    context "when offer has custom fields" do
      it "maps a Greenhouse candidate into a Namely profile" do
        expect(map_fixture("greenhouse_payload_offer_custom_fields")).to eq(
          first_name: "Johnny",
          last_name: "Smith",
          personal_email: "personal@example.com",
          email: "work@example.com",
          user_status: "active",
          start_date: "2015-01-23",
          home: { address1: "455 Broadway New York, NY 10280" },
          greenhouse_id: "20",
          salary: {
            yearly_amount: 70000,
            currency_type: "USD",
            date: "2015-01-23"
          },
          middle_name: "Attila",
        )
      end
    end

    context "when job has custom fields" do
      it "maps a Greenhouse candidate into a Namely profile" do
        expect(map_fixture("greenhouse_payload_job_custom_fields")).to eq(
          first_name: "Johnny",
          last_name: "Smith",
          personal_email: "personal@example.com",
          email: "work@example.com",
          user_status: "active",
          start_date: "2015-01-23",
          home: { address1: "455 Broadway New York, NY 10280" },
          greenhouse_id: "20",
          salary: {
            yearly_amount: 70000,
            currency_type: "USD",
            date: "2015-01-23"
          },
          middle_name: "Test",
        )
      end
    end

    context "handle missing none mandatory fields" do
      it "return default values when not present in payload" do
        expect(map_fixture("greenhouse_payload_missing")).to eq(
          first_name: "Johnny",
          last_name: "Smith",
          personal_email: "personal@example.com",
          email: "work@example.com",
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
          },
          "job" => {
            "custom_fields" => {}
          },
          "offer" => {
            "starts_at" => "2015-06-20",
            "custom_fields" => {}
          },
          "id" => "greenhouse_id"
        } }

        expect(map(greenhouse_candidate)).to eq(
          first_name: "Johnny",
          last_name: "Smith",
          personal_email: "personal@example.com",
          user_status: "active",
          greenhouse_id: "greenhouse_id",
          start_date: "2015-06-20",
        )
      end

      it "return default blank for email if nil" do
        greenhouse_candidate = {'application' => {
          "candidate" => {
            "first_name" => "Johnny",
            "last_name" => "Smith",
            "email_addresses" => nil,
            "addresses" => nil
          },
          "job" => {
            "custom_fields" => {}
          },
          "offer" => {
            "starts_at" => "2015-06-20",
            "custom_fields" => {}
          },
          "id" => "greenhouse_id"
        } }

        expect(map(greenhouse_candidate)).to eq(
          first_name: "Johnny",
          last_name: "Smith",
          user_status: "active",
          greenhouse_id: "greenhouse_id",
          start_date: "2015-06-20",
        )
      end
    end
  end

  describe "#namely_identifier_field" do
    it "returns the custom Namely field that stores the Greenhouse ID" do
      expect(build_mapper.namely_identifier_field).to eq(:greenhouse_id)
    end
  end

  def map_fixture(name)
    json = File.read("spec/fixtures/api_requests/#{name}.json")
    candidate = JSON.parse(json)["payload"]
    map(candidate)
  end

  def map(candidate)
    build_mapper.call(candidate)
  end

  def build_mapper
    Greenhouse::Normalizer.new(
      attribute_mapper: build_attribute_mapper,
      namely_fields: namely_fields
    )
  end

  def build_attribute_mapper
    create(:greenhouse_connection).attribute_mapper
  end
end
