require "rails_helper"

describe NamelyJobTitle do
  describe "#job_title" do
    it "finds the correct job title" do
      namely_job_title = described_class.new(
        job_title_name: "VP of thought leadership hacking",
        namely_connection: namely_connection,
      )
      stub_job_titles

      expect(namely_job_title.job_title).to eq("5000")
    end
  end

  def namely_connection
    @namely_connection ||= create(:user).namely_connection
  end

  def stub_job_tiers
  end

  def stub_job_titles
    allow(namely_connection).
      to receive_message_chain(:job_titles, :all).
      and_return([job_title])
  end

  def job_title
    double("job_title", id: "5000", title: "VP of thought leadership hacking")
  end
end
