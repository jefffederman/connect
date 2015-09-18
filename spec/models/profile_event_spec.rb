require "rails_helper"

describe ProfileEvent do
  describe ".ordered" do
    it "orders alphabetically by profile name" do
      create(:profile_event, profile_name: "NameA")
      create(:profile_event, profile_name: "NameC")
      create(:profile_event, profile_name: "NameB")

      result = ProfileEvent.ordered

      expect(result.map(&:profile_name)).to eq(%w(NameA NameB NameC))
    end
  end

  describe ".create_from_result!" do
    context "with a successful result" do
      it "creates a successful profile event" do
        sync_summary = create(:sync_summary)
        result = double(
          :result,
          name: "Name",
          error: nil,
          profile_id: "abc123"
        )

        profile_event = sync_summary.profile_events.create_from_result!(result)

        expect(profile_event).to be_persisted
        expect(profile_event).to be_successful
        expect(profile_event.profile_name).to eq("Name")
        expect(profile_event.profile_id).to eq("abc123")
      end
    end

    context "with an unsuccessful result" do
      it "creates an unsuccessful profile event" do
        sync_summary = create(:sync_summary)
        result = double(
          :result,
          name: "Name",
          error: "Failure",
          profile_id: "abc123"
        )

        profile_event = sync_summary.profile_events.create_from_result!(result)

        expect(profile_event).to be_persisted
        expect(profile_event).not_to be_successful
        expect(profile_event.profile_id).to eq("abc123")
      end
    end
  end

  describe ".successful" do
    it "returns profile events without errors" do
      create(:profile_event, profile_name: "Success1", error: nil)
      create(:profile_event, profile_name: "Failure", error: "Bad")
      create(:profile_event, profile_name: "Success2", error: nil)

      result = ProfileEvent.successful

      expect(result.map(&:profile_name)).to match_array(%w(Success1 Success2))
    end
  end

  describe ".failed" do
    it "returns profile events with errors" do
      create(:profile_event, profile_name: "Failure1", error: "Bad")
      create(:profile_event, profile_name: "Success", error: nil)
      create(:profile_event, profile_name: "Failure2", error: "Bad")

      result = ProfileEvent.failed

      expect(result.map(&:profile_name)).to match_array(%w(Failure1 Failure2))
    end
  end
end
