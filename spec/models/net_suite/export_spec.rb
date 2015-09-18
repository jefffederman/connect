require "rails_helper"

describe NetSuite::Export do
  describe "#perform" do
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

        net_suite = stub_net_suite { { "internalId" => "1234" } }
        mapped_attributes = double("mapped_attributes")
        normalizer = stub_normalizer(to: mapped_attributes)

        results = perform_export(
          normalizer: normalizer,
          net_suite: net_suite,
          profiles: profiles
        )

        expect(results.map(&:success?)).to eq([true, true])
        expect(results.map(&:updated?)).to eq([false, false])
        expect(results.map(&:name)).to eq(names)
        expect(results.map(&:profile_id)).to eq(ids)
        expect(net_suite).to have_received(:create_employee).
          with(mapped_attributes).
          exactly(2)
        profiles.each do |profile|
          expect(profile).to have_received(:update).with(netsuite_id: "1234")
        end
      end
    end

    context "with an already-exported employee" do
      it "returns a result with updated profiles" do
        profile = stub_profile(netsuite_id: "1234")
        mapped_attributes = double("mapped_attributes")
        normalizer = stub_normalizer(
          from: profile,
          to: mapped_attributes
        )
        net_suite = stub_net_suite { {} }

        results = perform_export(
          normalizer: normalizer,
          net_suite: net_suite,
          profiles: [profile]
        )

        expect(results.map(&:updated?)).to eq([true])
        expect(net_suite).to have_received(:update_employee).
          with("1234", mapped_attributes)
      end
    end

    context "with an invalid employee" do
      it "returns a failure result" do
        profile = stub_profile
        exception = double(
          :exception,
          response: { "message" => "invalid employee" }.to_json,
          http_code: 499
        )
        error = NetSuite::ApiError.new(exception)
        net_suite = stub_net_suite { raise error }

        results = perform_export(net_suite: net_suite, profiles: [profile])

        expect(results.map(&:success?)).to eq([false])
        expect(results.map(&:error)).to eq([error.to_s])
        expect(profile).not_to have_received(:update)
      end
    end
  end

  def build_namely_connection
    create(:user).namely_connection
  end

  def stub_profile(overrides = {})
    double(:profile).tap do |profile|
      attributes = {
        id: "83809753-615b-44ee-914b-3821fe2ee7ae",
        first_name: "Sally",
        last_name: "Smith",
        email: "sally.smith@example.com",
        start_date: "07/18/2013",
        gender: "Female",
        home_phone: "123-123-1234",
        netsuite_id: ""
      }.merge(overrides)

      stub_attributes(profile, attributes)
      allow(profile).to receive(:update)
      allow(profile).to receive(:name).and_return(
        "#{attributes[:first_name]} #{attributes[:last_name]}"
      )
    end
  end

  def stub_attributes(profile, attributes)
    attributes.each do |name, value|
      allow(profile).
        to receive(:[]).
        with(name.to_s).
        and_return(Fields::StringValue.new(value))
    end

    allow(profile).to receive(:id).and_return(attributes[:id])
  end

  def stub_net_suite(&block)
    double("net_suite").tap do |net_suite|
      allow(net_suite).to receive(:create_employee, &block)
      allow(net_suite).to receive(:update_employee, &block)
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

  def perform_export(
    normalizer: stub_normalizer,
    net_suite:,
    profiles:
  )
    NetSuite::Export.new(
      normalizer: normalizer,
      net_suite: net_suite,
      namely_profiles: profiles
    ).perform
  end
end
