require "rails_helper"

describe SyncSummary do
  describe ".create_from_results" do
    it "creates a sync summary for the connection with the given results" do
      names = %w(Billy Wendy Franko)
      results = names.map { |name| stub_profile(name: name) }
      connection = create(:net_suite_connection)

      summary = SyncSummary.create_from_results!(
        results: results,
        connection: connection
      )

      expect(summary).to be_persisted
      expect(summary.profile_events.pluck(:profile_name)).to match_array(names)
    end
  end

  describe ".ordered" do
    it "orders by created_at, descending" do
      oldest = create(:sync_summary)
      newest = create(:sync_summary)

      expect(SyncSummary.ordered).to eq [newest, oldest]
    end
  end

  describe "#failed_profiles" do
    it "returns profiles corresponding to the failed profile events" do
      failed_event = create(
        :profile_event,
        error: "Something went wrong",
        profile_id: "abc-def",
        profile_name: "Derek",
      )
      sync_summary = failed_event.sync_summary
      failed_profile = double("Failed Profile", id: failed_event.profile_id)
      allow(sync_summary.installation).to receive(:namely_profiles).and_return([
        double("Profile", id: "xxx-zzz"),
        failed_profile
      ])

      expect(sync_summary.failed_profiles).to eq [failed_profile]
    end
  end

  describe "#retry" do
    it "uses the connection to retry profiles from the sync summary" do
      sync_summary = create(:sync_summary)
      allow(sync_summary.connection).to receive(:retry)

      sync_summary.retry

      expect(sync_summary.connection).to have_received(:retry).
        with(sync_summary)
    end
  end

  def stub_profile(name:)
    double(:result, profile_id: "x", name: name, error: nil)
  end
end
