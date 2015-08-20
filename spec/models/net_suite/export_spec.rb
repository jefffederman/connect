require "rails_helper"

describe NetSuite::Export do
  describe "#perform" do
    context "with new, valid employees" do
      it "returns a result with created profiles" do
        emails = %w(one@example.com two@example.com)
        profile_data = [
          {
            email: "one@example.com",
            first_name: "One",
            last_name: "Last"
          },
          {
            email: "two@example.com",
            first_name: "Two",
            last_name: "Last"
          }
        ]
        profiles = profile_data.map { |profile| stub_profile(profile) }
        emails = profile_data.map { |profile| profile[:email] }
        names = profile_data.map do |profile|
          "#{profile[:first_name]} #{profile[:last_name]}"
        end

        net_suite = stub_net_suite(success: true, internalId: "1234")
        mapped_attributes = double("mapped_attributes")
        normalizer = stub_normalizer(to: mapped_attributes)

        results = perform_export(
          normalizer: normalizer,
          net_suite: net_suite,
          profiles: profiles
        )

        expect(results.map(&:success?)).to eq([true, true])
        expect(results.map(&:updated?)).to eq([false, false])
        expect(results.map(&:email)).to eq(emails)
        expect(results.map(&:name)).to eq(names)
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
        profile = stub_profile({}, netsuite_id: "1234")
        mapped_attributes = double("mapped_attributes")
        normalizer = stub_normalizer(
          from: profile,
          to: mapped_attributes
        )
        net_suite = stub_net_suite(success: true)

        results = perform_export(
          normalizer: normalizer,
          net_suite: net_suite,
          profiles: [profile]
        )

        expect(results.map(&:email)).to eq([profile.email])
        expect(results.map(&:updated?)).to eq([true])
        expect(net_suite).to have_received(:update_employee).
          with("1234", mapped_attributes)
      end
    end

    context "with an invalid employee" do
      it "returns a failure result" do
        message = "invalid employee"
        profile = stub_profile(email: "example")
        net_suite = stub_net_suite(success: false, message: message)

        results = perform_export(net_suite: net_suite, profiles: [profile])

        expect(results.map(&:success?)).to eq([false])
        expect(results.map(&:message)).to eq([message])
        expect(profile).not_to have_received(:update)
      end
    end
  end

  def build_namely_connection
    create(:user).namely_connection
  end

  def stub_profile(overrides = {}, data = {})
    data.stringify_keys.tap do |profile|
      attributes = {
        id: "83809753-615b-44ee-914b-3821fe2ee7ae",
        first_name: "Sally",
        last_name: "Smith",
        email: "sally.smith@example.com",
        start_date: "07/18/2013",
        gender: "Female",
        home_phone: "123-123-1234",
        job_title:
        {
          id: "0c601728-2658-4677-a22b-1c8653b431ae",
          title: "CEO"
        }
      }.merge(overrides)

      allow(profile).to receive(:update)

      attributes.each do |name, value|
        allow(profile).to receive(name).and_return(value)
      end

      allow(profile).to receive(:name).and_return(
        "#{profile.first_name} #{profile.last_name}"
      )
    end
  end

  def stub_net_suite(arguments = {})
    double("net_suite").tap do |net_suite|
      response = arguments.stringify_keys.except("success")
      allow(response).to receive(:success?).and_return(arguments[:success])
      allow(net_suite).to receive(:create_employee).and_return(response)
      allow(net_suite).to receive(:update_employee).and_return(response)
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
