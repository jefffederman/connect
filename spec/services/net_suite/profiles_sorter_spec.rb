require_relative "../../../app/services/net_suite/profiles_sorter"

describe NetSuite::ProfilesSorter do
  subject(:sorter) { described_class.new(profiles: profiles) }

  describe "#to_a" do
    context "when profiles have reports to another profile" do
      let(:profiles) do
        [profile_with_manager, profile_manager, another_profile_with_manager]
      end
      let(:profile_with_manager) do
        double :profile_with_manager,
          guid: "profile_guid",
          reports_to: [ id: profile_manager.guid ]
      end
      let(:another_profile_with_manager) do
        double :another_profile_with_manager,
          guid: "another_profile_guid",
          reports_to: [ id: profile_manager.guid]
      end
      let(:profile_manager) do
        double :manager,
          guid: "my_guid",
          reports_to: [ id: "another_guid_manager" ]
      end

      it "returns an array with the manager before the one who reports to" do
        expect(sorter.call).to match_array [
          profile_manager,
          profile_with_manager,
          another_profile_with_manager
        ]
      end
    end

    context "when profiles doesn't have reports to" do
      let(:profiles) do
        [profile_without_manager, profile_manager, another_profile_without_manager]
      end
      let(:profile_without_manager) do
        double :profile_without_manager,
          guid: "profile_guid",
          reports_to: [ ]
      end
      let(:another_profile_without_manager) do
        double :another_profile_without_manager,
          guid: "another_profile_guid",
          reports_to: [ ]
      end
      let(:profile_manager) do
        double :manager,
          guid: "my_guid",
          reports_to: [ ]
      end

      it "returns an array with the profiles" do
        expect(sorter.call).to match_array [
          profile_without_manager,
          profile_manager,
          another_profile_without_manager
        ]
      end
    end
  end
end
