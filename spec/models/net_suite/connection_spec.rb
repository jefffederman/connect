require "rails_helper"

describe NetSuite::Connection do
  describe "validations" do
    it { is_expected.to allow_value(nil).for(:subsidiary_id) }
    it { is_expected.not_to allow_value("").for(:subsidiary_id) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:attribute_mapper).dependent(:destroy) }
    it { is_expected.to belong_to(:installation) }
  end

  describe "#connected?" do
    context "with saved authorization data" do
      it "returns true" do
        expect(NetSuite::Connection.new(instance_id: "x", authorization: "y")).
          to be_connected
      end
    end

    context "without authorization data" do
      it "returns false" do
        expect(NetSuite::Connection.new(instance_id: nil, authorization: "y")).
          not_to be_connected
        expect(NetSuite::Connection.new(instance_id: "x", authorization: nil)).
          not_to be_connected
      end
    end
  end

  describe "#enabled?" do
    context "with Cloud Elements configuration" do
      it "returns true" do
        ClimateControl.modify CLOUD_ELEMENTS_ORGANIZATION_SECRET: "abc" do
          expect(NetSuite::Connection.new).to be_enabled
        end
      end
    end

    context "without Cloud Elements configuration" do
      it "returns false" do
        ClimateControl.modify CLOUD_ELEMENTS_ORGANIZATION_SECRET: nil do
          expect(NetSuite::Connection.new).not_to be_enabled
        end
      end
    end
  end

  describe "#ready?" do
    context "with a subsidiary" do
      it "returns true" do
        expect(NetSuite::Connection.new(subsidiary_id: "x")).to be_ready
      end
    end

    context "without a subsidiary" do
      it "returns false" do
        expect(NetSuite::Connection.new(subsidiary_id: nil)).not_to be_ready
      end
    end
  end

  describe "#attribute_mapper" do
    it "builds and saves an attribute mapper" do
      connection = NetSuite::Connection.new(
        subsidiary_id: "x",
        authorization: "x",
        installation: create(:installation)
      )
      client = stub_client(authorization: "x")
      profile_fields = [
        double(id: "email", name: "email", type: "text"),
        double(id: "initials", name: "initials", type: "text"),
        double(id: "unsupported", name: "unsupported", type: "file"),
      ]
      allow(client).to receive(:profile_fields).and_return(profile_fields)

      connection.save!

      expect(connection.attribute_mapper).to be_an_instance_of(AttributeMapper)
      expect(connection.attribute_mapper).to be_persisted
      expect(mapped_fields(connection.attribute_mapper)).to match_array([
        %w(email email),
        %w(firstName first_name),
        %w(gender gender),
        %w(phone home_phone),
        %w(title job_title),
        %w(lastName last_name),
        ["initials", nil],
      ])
    end
  end

  describe "#client" do
    it "configures a client with its authorization" do
      client = stub_client(authorization: "x")
      connection = NetSuite::Connection.new(authorization: "x")

      result = connection.client

      expect(result).to eq(client)
    end
  end

  describe "#subsidiaries" do
    it "delegates to its client" do
      subsidiaries = [
        { "internalId" => "1", "name" => "Apple" },
        { "internalId" => "2", "name" => "Banana" }
      ]
      connection = NetSuite::Connection.new(authorization: "x")
      client = stub_client(authorization: "x")
      allow(client).to receive(:subsidiaries).and_return(subsidiaries)

      result = connection.subsidiaries

      expect(result).to eq([%w(Apple 1), %w(Banana 2)])
    end
  end

  describe "#sync" do
    it "exports to NetSuite" do
      namely_profiles = double(:namely_profiles)
      client = stub_client(authorization: "x")
      allow(client).to receive(:profile_fields).and_return([])
      connection = create(:net_suite_connection, authorization: "x")
      allow(connection.installation).
        to receive(:namely_profiles).
        and_return(namely_profiles)
      results = double(:results)
      export = double(NetSuite::Export, perform: results)
      normalizer = double("normalizer")
      allow(NetSuite::Normalizer).
        to receive(:new).
        with(
          attribute_mapper: connection.attribute_mapper,
          configuration: connection
        ).
        and_return(normalizer)
      allow(NetSuite::Export).
        to receive(:new).
        with(
          normalizer: normalizer,
          namely_profiles: namely_profiles,
          net_suite: client
        ).
        and_return(export)

      connection.sync

      expect(export).to have_received(:perform)
    end
  end

  describe "#export" do
    it do
      should delegate_method(:export).
        to(:normalizer).
        as(:export)
    end
  end

  def stub_client(authorization:)
    double(:authorized_client).tap do |authorized_client|
      client_from_env = double(:client_from_env)
      allow(NetSuite::Client).to receive(:from_env).and_return(client_from_env)
      allow(client_from_env).
        to receive(:authorize).
        with(authorization).
        and_return(authorized_client)
    end
  end

  def mapped_fields(attribute_mapper)
    attribute_mapper.field_mappings.map do |field_mapping|
      [field_mapping.integration_field_id, field_mapping.namely_field_name]
    end
  end
end
