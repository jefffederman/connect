require "rails_helper"

describe Profile do
  describe "delegations" do
    subject { Profile.new({}, fields: double(:fields)) }
    it { should delegate_method(:update).to(:namely_profile) }
  end

  describe "#[]" do
    it "exports a value from its fields" do
      data = double(:data)
      fields = double(:fields)
      value = double(:value)
      allow(fields).
        to receive(:export).
        with("job_title", from: data).
        and_return(value)
      profile = Profile.new(data, fields: fields)

      result = profile["job_title"]

      expect(result).to eq(value)
    end
  end

  describe "#id" do
    it "returns the raw ID" do
      profile_data = { id: "uvx" }
      fields = double(:fields)
      profile = Profile.new(profile_data, fields: fields)

      result = profile.id

      expect(result).to eq("uvx")
    end
  end

  describe "#name" do
    it "returns #first_name #last_name" do
      profile_data = {
        first_name: "First",
        last_name: "Last"
      }
      fields = double(:fields)
      profile = Profile.new(profile_data, fields: fields)

      expect(profile.name).to eq("First Last")
    end
  end
end
