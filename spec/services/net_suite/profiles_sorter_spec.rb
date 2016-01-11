require_relative "../../../app/services/net_suite/profiles_sorter"

describe NetSuite::ProfilesSorter do
  subject(:sorter) { described_class.new(profiles: profiles) }

  describe "#call" do
    context "when profiles have reports to another profile" do
      let(:profiles) do
        [profile_with_manager, profile_manager, another_profile_with_manager]
      end
      let(:profile_with_manager) do
        double :profile_with_manager,
          guid: "12fe28cc-7a44-43b0-8062-cad75e2b41ce",
          reports_to: [ id: profile_manager.guid ]
      end
      let(:another_profile_with_manager) do
        double :another_profile_with_manager,
          guid: "66303d81-7dae-4759-866b-4b66689dcc0b",
          reports_to: [ id: profile_manager.guid]
      end
      let(:profile_manager) do
        double :manager,
          guid: "154da20f-870e-4a5b-9ef8-b1f0bbd890cb",
          reports_to: [ id: "e614235f-3b7c-45f5-b2e2-b271b6ffa9fd" ]
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
          guid: "12fe28cc-7a44-43b0-8062-cad75e2b41ce"
      end
      let(:another_profile_without_manager) do
        double :another_profile_without_manager,
          guid: "66303d81-7dae-4759-866b-4b66689dcc0b"
      end
      let(:profile_manager) do
        double :manager,
          guid: "154da20f-870e-4a5b-9ef8-b1f0bbd890cb"
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

  context "when profiles has a nil reports to" do
    let(:profiles) do
      [profile_without_manager, profile_manager, another_profile_without_manager]
    end
    let(:profile_without_manager) do
      double :profile_without_manager,
        guid: "12fe28cc-7a44-43b0-8062-cad75e2b41ce",
        reports_to: nil
    end
    let(:another_profile_without_manager) do
      double :another_profile_without_manager,
        guid: "66303d81-7dae-4759-866b-4b66689dcc0b",
        reports_to: nil
    end
    let(:profile_manager) do
      double :manager,
        guid: "154da20f-870e-4a5b-9ef8-b1f0bbd890cb",
        reports_to: nil
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
