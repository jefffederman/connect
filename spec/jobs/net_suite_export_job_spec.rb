require "rails_helper"
describe NetSuiteExportJob do
  let(:cloud_elements) do
    "https://api.cloud-elements.com/elements/api-v2/hubs/erp"
  end
  describe "perform" do

    context "when operation is not valid" do
      it "logs an error then returns" do
        job = described_class.new
        expect(job.logger).to receive(:error)
        job.perform("invalid", nil,  nil, nil, nil, nil)
      end
    end

    context "when operation is update and netsuite_id is empty" do
      it "logs an error then returns" do
        job = described_class.new
        expect(job.logger).to receive(:error)
        job.perform("update", nil,  nil, nil, nil, nil)
      end
    end

    context "when netsuite connection does not exist" do
      it "logs an error then returns" do
        job = described_class.new
        expect(job.logger).to receive(:error)
        job.perform("update", nil,  22, nil, nil, nil)
      end
    end

    context "when operation is create" do
      it "exports employee and creates profile event" do
        job = described_class.new
        installation = create(:installation)
        create(:user, installation: installation)
        connection = create(
          :net_suite_connection,
          :connected,
          :with_namely_field,
          :ready,
          installation: installation
        )
        summary = create(:sync_summary, connection: connection)

        req = stub_request(:post, "#{cloud_elements}/employees").
          to_return(status: 200, body: { "internalId" => "22" }.to_json)

        stub_request(:put, %r{.*api/v1/profiles/.*}).to_return(status: 200)

        job.perform("create", summary.id,  connection.id, 22, "NAME", {"firstName": "NAME"})

        expect(req).to have_been_requested
        expect(summary.profile_events.count).to eq(1)
      end
    end

    context "when operation is update" do
      it "exports employee and creates profile event" do
        job = described_class.new
        installation = create(:installation)
        create(:user, installation: installation)
        connection = create(
          :net_suite_connection,
          :connected,
          :with_namely_field,
          :ready,
          installation: installation
        )
        summary = create(:sync_summary, connection: connection)

        req = stub_request(:patch, "#{cloud_elements}/employees/22").
          to_return(status: 200, body: { "internalId" => "22" }.to_json)

        stub_request(:put, %r{.*api/v1/profiles/.*}).to_return(status: 200)

        job.perform("update", summary.id,  connection.id, 22, "NAME", {"firstName": "NAME"}, 22)

        expect(req).to have_been_requested
        expect(summary.profile_events.count).to eq(1)
      end
    end
  end
end
