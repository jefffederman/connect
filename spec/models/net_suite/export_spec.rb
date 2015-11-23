require "rails_helper"

describe NetSuite::Export do
  describe "#perform" do
    let(:employee_data) { [] }
    context "with new, valid employees" do
      it "returns a result with created profiles" do
        profile_data = [
          {
            id: "abc123",
            email: "one@example.com",
            first_name: "One",
            last_name: "Last"
          },
          {
            id: "def456",
            email: "two@example.com",
            first_name: "Two",
            last_name: "Last"
          }
        ]
        profiles = profile_data.map { |profile| stub_profile(profile) }
        ids = profile_data.map { |profile| profile[:id] }
        names = profile_data.map do |profile|
          "#{profile[:first_name]} #{profile[:last_name]}"
        end

        net_suite_connection = stub_net_suite_connection { { "internalId" => "1234" } }
        mapped_attributes = {"netsuite_id" => "", }
        normalizer = stub_normalizer(to: mapped_attributes)

        expect_create_job(
          net_suite_connection.id,
          profiles[0].id,
          profiles[0].name,
          mapped_attributes,
        )
        expect_create_job(
          net_suite_connection.id,
          profiles[1].id,
          profiles[1].name,
          mapped_attributes,
        )

        perform_export(
          normalizer: normalizer,
          net_suite_connection: net_suite_connection,
          profiles: profiles
        )
      end
    end

    context "with an already-exported employee" do
      let(:employee_data) do
        [
          {
            "firstName" => "Alex",
            "lastName" => "Test",
            "internalId" => "1234",
            "email" => "alex@example.com"
          }
        ]
      end
      it "returns a result with updated profiles" do
        profile = stub_profile(netsuite_id: "1234")
        mapped_attributes = {
          "internalId" => "1234",
          "firstName" => profile.first_name,
          "lastName" => profile.last_name,
          "email" => profile.email,
          "addressbookList" => {
            "addressbook" => [
              {
                "defaultShipping" => true,
                "addressbookAddress" => {
                  "addr1" => "",
                  "addr2" => "",
                  "city" => "",
                  "state" => "",
                  "zip" => "",
                }
              }
            ]
          }
        }
        normalizer = stub_normalizer(
          from: profile,
          to: mapped_attributes
        )
        net_suite_connection = stub_net_suite_connection { { "internalId" => "1234" } }

        expect_update_job(
          net_suite_connection.id,
          profile.id,
          profile.name,
          mapped_attributes,
          "1234"
        )

        results = perform_export(
          normalizer: normalizer,
          net_suite_connection: net_suite_connection,
          profiles: [profile]
        )
      end
    end

    context "with unmatched employees" do
      let(:employee_data) do
        [
          {
            "firstName" => "Alex",
            "lastName" => "Test",
            "internalId" => "1234",
            "email" => "alex@example.com"
          }
        ]
      end
      it "returns a result with updated profiles" do
        profile = stub_profile(netsuite_id: "42332", email: "test@example.com")
        mapped_attributes = {
          "internalId" => "42332",
          "firstName" => profile.first_name,
          "lastName" => profile.last_name,
          "email" => profile.email,
          "addressbookList" => {
            "addressbook" => [
              {
                "defaultshipping" => true,
                "addressbookaddress" => {
                  "addr1" => "",
                  "addr2" => "",
                  "city" => "",
                  "state" => "",
                  "zip" => "",
                }
              }
            ]
          }
        }
        normalizer = stub_normalizer(
          from: profile,
          to: mapped_attributes
        )
        net_suite_connection = stub_net_suite_connection { { } }

        expect_create_job(
          net_suite_connection.id,
          profile.id,
          profile.name,
          mapped_attributes
        )

        results = perform_export(
          normalizer: normalizer,
          net_suite_connection: net_suite_connection,
          profiles: [profile]
        )
      end
    end

    context "with matched employees that don't have a netsuite_id" do
      let(:employee_data) do
        [
          {
            "firstName" => "Alex",
            "lastName" => "Test",
            "internalId" => "1234",
            "email" => "alex@example.com"
          }
        ]
      end
      it "returns a result with updated profiles" do
        profile = stub_profile(netsuite_id: "", email: "alex@example.com")
        mapped_attributes = {
          "internalId" => "",
          "firstName" => profile.first_name,
          "lastName" => profile.last_name,
          "email" => profile.email,
          "addressbookList" => {
            "addressbook" => [
              {
                "defaultshipping" => true,
                "addressbookaddress" => {
                  "addr1" => "",
                  "addr2" => "",
                  "city" => "",
                  "state" => "",
                  "zip" => "",
                }
              }
            ]
          }
        }
        normalizer = stub_normalizer(
          from: profile,
          to: mapped_attributes
        )
        net_suite_connection = stub_net_suite_connection { {} }

        expect_update_job(
          net_suite_connection.id,
          profile.id,
          profile.name,
          mapped_attributes,
          "1234"
        )

        results = perform_export(
          normalizer: normalizer,
          net_suite_connection: net_suite_connection,
          profiles: [profile]
        )
      end
    end
  end

  def build_namely_connection
    create(:user).namely_connection
  end

  def stub_profile(overrides = {})
    profile = build(:namely_profile, overrides)

    allow(profile).to receive(:update)
    allow(profile).to receive(:name).and_return(
      "#{profile.first_name} #{profile.last_name}"
    )

    profile
  end

  def stub_net_suite_connection(&block)
    client = double("net_suite_client").tap do |net_suite|
      allow(net_suite).to receive(:create_employee, &block)
      allow(net_suite).to receive(:update_employee, &block)
      allow(net_suite).to receive(:employees).and_return(employee_data)
    end

    double("net_suite_connection", client: client).tap do |connection|
      allow(connection).to receive(:id).and_return(22)
      allow(connection).to receive(:subsidiary_id).and_return(1)
    end
  end

  def stub_normalizer(from: anything, to: double("attributes"))
    double("normalizer").tap do |normalizer|
      allow(normalizer).
        to receive(:export).
        with(from).
        at_least(1).
        and_return(to)
    end
  end

  def expect_update_job(profile_id, profile_name, connection_id, attributes, netsuite_id)
    expect(NetSuiteExportJob).to receive(:perform_later).
      with(
        "update",
        2,
        profile_id,
        profile_name,
        connection_id,
        attributes,
        netsuite_id
      )
  end

  def expect_create_job(profile_id, profile_name, connection_id, attributes)
    expect(NetSuiteExportJob).to receive(:perform_later).
      with(
        "create",
        2,
        profile_id,
        profile_name,
        connection_id,
        attributes
      )
  end

  def perform_export(
    normalizer: stub_normalizer,
    net_suite_connection:,
    profiles:
  )
    NetSuite::Export.new(
      summary_id: 2,
      normalizer: normalizer,
      net_suite_connection: net_suite_connection,
      namely_profiles: profiles
    ).perform
  end
end
