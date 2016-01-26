require_relative "../../../app/services/net_suite/profiles_sorter"

describe NetSuite::ProfilesSorter do
  subject(:sorter) { described_class.new(profiles: profiles) }

  describe "#call" do
    context "when there are no profiles" do
      let(:profiles) { [] }
      it "returns an empty list" do
        expect(sorter.call).to eql []
      end
    end

    context "when a profile have one manager and it have the proper order" do
      let(:profile_with_manager) do
        double :profile_with_manager,
          id: "12fe28cc-7a44-43b0-8062-cad75e2b41ce",
          netsuite_id: -2,
          reports_to: [ double(:reports_to, id: profile_manager.id) ]
      end
      let(:profile_manager) do
        double :manager,
          id: "66303d81-7dae-4759-866b-4b66689dcc0b",
          netsuite_id: -1,
          reports_to: []
      end
      let(:profiles) do
        [
          profile_manager,
          profile_with_manager
        ]
      end

      it "returns the manager at the top of the list" do
        expect(sorter.call).to eql [
          profile_manager,
          profile_with_manager
        ]
      end

      it "generates a new netsuite supervisor id field" do
        expect(
          sorter.call.map do |profile|
            [profile.id, profile.netsuite_supervisor_id]
          end.last
        ).to eql ["12fe28cc-7a44-43b0-8062-cad75e2b41ce", -1]
      end
    end

    context "when a manager has two dependant profiles not in the proper order" do
      let(:profile_with_manager) do
        double :profile_with_manager,
          id: "12fe28cc-7a44-43b0-8062-cad75e2b41ce",
          reports_to: [ double(:reports_to, id: profile_manager.id) ]
      end
      let(:profile_manager) do
        double :manager,
          id: "66303d81-7dae-4759-866b-4b66689dcc0b",
          reports_to: []
      end
      let(:another_profile_with_manager) do
        double :another_profile_with_manager,
          id: "154da20f-870e-4a5b-9ef8-b1f0bbd890cb",
          reports_to: [ double(:reports_to, id: profile_manager.id) ]
      end

      context "proper order" do
        let(:profiles) do
          [
            profile_manager,
            profile_with_manager,
            another_profile_with_manager
          ]
        end
        it "returns the manager first" do
          expect(sorter.call).to eql [
            profile_manager,
            another_profile_with_manager,
            profile_with_manager,
          ]
        end
      end

      context "shuffle order" do
        let(:profiles) do
          [
            another_profile_with_manager,
            profile_manager,
            profile_with_manager
          ]
        end
        it "returns the manager first" do
          expect(sorter.call).to eql [
            profile_manager,
            profile_with_manager,
            another_profile_with_manager
          ]
        end
      end
    end

    context "when profiles have reports to a deeper profile" do
      let(:profiles) do
        [
          yet_another_profile,
          profile_with_manager,
          profile_manager,
          another_profile_with_manager
        ]
      end
      let(:profile_manager) do
        double :manager,
          id: "66303d81-7dae-4759-866b-4b66689dcc0b",
          reports_to: []
      end
      let(:profile_with_manager) do
        double :profile_with_manager,
          id: "12fe28cc-7a44-43b0-8062-cad75e2b41ce",
          reports_to: [ double(:reports_to, id: profile_manager.id) ]
      end
      let(:another_profile_with_manager) do
        double :another_profile_with_manager,
          id: "154da20f-870e-4a5b-9ef8-b1f0bbd890cb",
          reports_to: [ double(:reports_to, id: profile_with_manager.id) ]
      end
      let(:yet_another_profile) do
        double :yet_another_profile,
          id: "154da20f-870e-4a5b-9ef8-b1f0bbd890cb",
          reports_to: [ double(:reports_to, id: another_profile_with_manager.id) ]
      end

      it "returns an array with the manager before the one who reports to" do
        expect(sorter.call).to eql [
          profile_manager,
          profile_with_manager,
          another_profile_with_manager,
          yet_another_profile,
        ]
      end
    end

    context "when profiles doesn't have reports to" do
      let(:profiles) do
        [profile_without_manager]
      end
      let(:profile_without_manager) do
        double :profile_without_manager,
          id: "12fe28cc-7a44-43b0-8062-cad75e2b41ce"
      end

      it "returns an array with the profiles" do
        expect(sorter.call).to eql [profile_without_manager]
      end
    end
  end

  context "when profiles has a nil reports to" do
    let(:profiles) do
      [profile_without_manager]
    end
    let(:profile_without_manager) do
      double :profile_without_manager,
        id: "12fe28cc-7a44-43b0-8062-cad75e2b41ce",
        reports_to: nil
    end

    it "returns an array with the profiles" do
      expect(sorter.call).to eql [profile_without_manager]
    end
  end
end
