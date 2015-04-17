require "rails_helper"

describe NamelyJobTitle do
  describe "#job_title" do
    it "finds the correct job title" do
      namely_job_title = described_class.new(
        job_title_name: "VP of thought leadership hacking",
        namely_connection: namely_connection,
      )

      expect(namely_job_title.job_title).to eq("5000")
    end
  end

  def namely_connection
    @namely_connection ||= create(:user).namely_connection
  end

  def job_tier_stubs
    stub_request(:get, "https://....namely.com/api/v1/job_tiers?access_token=...&limit=all").
         to_return(:status => 200, :body => "",)
  end
end
