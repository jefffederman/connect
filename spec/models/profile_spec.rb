require "rails_helper"

describe Profile do
  describe "delegations" do
    subject { Profile.new(stub_profile_data) }
    it { should delegate_method(:update).to(:namely_profile) }
  end

  describe "#[]" do
    context "with a hash" do
      it "finds the value of the first, non-id key" do
        profile = Profile.new(
          "job_title" => {
            "id" => "x",
            "title" => "expected",
          }
        )

        result = profile["job_title"]

        expect(result).to eq("expected")
      end
    end

    context "with other types" do
      it "returns the original value" do
        profile = Profile.new("name" => "expected")

        result = profile["name"]

        expect(result).to eq("expected")
      end
    end
  end

  describe "#name" do
    it "returns #first_name #last_name" do
      profile_data = stub_profile_data.merge(
        first_name: "First",
        last_name: "Last"
      )
      profile = Profile.new(profile_data)

      expect(profile.name).to eq("First Last")
    end
  end

  def stub_profile_data
    {
      email: "test@example.com",
      first_name: "First",
      last_name: "Last",
    }.merge(stub_job_title)
  end

  def stub_job_title(title = "Developer")
    {
      job_title: {
        "id" => "1234",
        "title" => title
      }
    }
  end
end
