require "rails_helper"

describe User do
  describe "associations" do
    it { is_expected.to belong_to(:installation) }
  end

  describe '#save_token_info' do
    let(:user) { create :user }

    it 'saves new access token and access token expires in info' do
      user.save_token_info('new_token', 'new_time')

      expect(user.access_token).to eql 'new_token'
    end
  end

  describe "#namely_profiles" do
    it "returns profiles from its Namely connection" do
      first_names = %w(Alice Bob)
      profile_list = first_names.map { |name| stub_namely_profile(name) }
      field_list = [double(:field, name: "first_name", type: "text")]

      profiles = double(:namely_profiles, all: profile_list)
      fields = double(:namely_fields, all: field_list)
      stub_namely_connection profiles: profiles, fields: fields
      user = User.new

      profile_first_names = user.namely_profiles.map do |profile|
        profile["first_name"].to_raw
      end

      expect(profile_first_names).to match_array(first_names)
    end
  end

  describe "#namely_connection" do
    it "returns a connection configured to use the user's credentials" do
      namely_connection = double("Namely::Connection")
      allow(Namely::Connection).to receive(:new).and_return(namely_connection)
      user = build(
        :user,
        access_token: "MY_ACCESS_TOKEN",
        subdomain: "ellingsonmineral",
      )

      result = user.namely_connection

      expect(result).to eq namely_connection
      expect(Namely::Connection).to have_received(:new).with(
        access_token: "MY_ACCESS_TOKEN",
        subdomain: "ellingsonmineral",
      )
    end
  end

  describe "#namely_fields_by_label" do
    it "returns mappable fields from a Namely connection alphabetically" do
      models = [
        double(name: "first_name", label: "First name", type: "text"),
        double(name: "last_name", label: "Last name", type: "longtext"),
        double(name: "gender", label: "Gender", type: "select"),
        double(name: "email", label: "Email", type: "email"),
        double(name: "job_title", label: "Job title", type: "referencehistory"),
        double(name: "user_status", label: "Status", type: "referenceselect"),
        double(name: "start_date", label: "started", type: "date"),
        double(name: "home", label: "Home address", type: "address"),
        stub_profile_field(type: "checkboxes"),
        stub_profile_field(type: "file"),
        stub_profile_field(type: "image"),
        stub_profile_field(type: "salary"),
      ]
      fields = double("fields", all: models)
      stub_namely_connection fields: fields
      user = User.new

      result = user.namely_fields_by_label

      expect(result).to eq([
        ["Email", "email"],
        ["First name", "first_name"],
        ["Gender", "gender"],
        ["Home address", "home"],
        ["Job title", "job_title"],
        ["Last name", "last_name"],
        ["started", "start_date"],
        ["Status", "user_status"],
      ])
    end

    def stub_profile_field(type:)
      double(name: type, label: "#{type} field", type: type)
    end
  end

  describe "#namely_fields" do
    it "returns fields from its Namely connection" do
      fields = double(:namely_fields)
      stub_namely_connection fields: fields
      user = User.new

      result = user.namely_fields

      expect(result).to eq(fields)
    end
  end

  def stub_namely_profile(first_name)
    { "first_name" => first_name }
  end

  def stub_namely_connection(attributes)
    namely_connection = double(:namely_connection, attributes)
    allow(Namely::Connection).to receive(:new).and_return(namely_connection)
    allow(Users::AccessTokenFreshener).to receive(:fresh_access_token)
  end
end
