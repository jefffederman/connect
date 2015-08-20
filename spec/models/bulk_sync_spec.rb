require "rails_helper"

describe BulkSync do
  include Features

  describe "#sync" do
    context "with a fully connected installation" do
      it "creates a sync job for each installation with the given connection" do
        user = create(:user)
        installation = user.installation
        create(
          :net_suite_connection,
          :connected,
          :with_namely_field,
          installation: installation
        )
        stub_namely_data("/profiles", "profiles_with_net_suite_fields")
        stub_request(:put, %r{.*api/v1/profiles/.*}).to_return(status: 200)
        stub_request(:get, %r{.*/api-v2/hubs/erp/employees}).
          to_return(status: 200, body: [{ "internalId" => "123" }].to_json)
        stub_request(:post, %r{.*/api-v2/hubs/erp/employees}).
          to_return(status: 200, body: { "internalId" => "123" }.to_json)
        stub_request(:patch, %r{.*/api-v2/hubs/erp/employees/.*}).
          to_return(status: 200, body: { "internalId" => "123" }.to_json)

        queue_sync installation

        expect(WebMock).not_to have_synced_a_profile

        run_queue

        expect(WebMock).to have_synced_a_profile.twice
      end
    end

    context "with a installation without a mapped Namely field" do
      it "doesn't sync" do
        installation = create(:installation)
        create(
          :net_suite_connection,
          :connected,
          found_namely_field: false,
          installation: installation
        )

        queue_sync installation
        run_queue

        expect(WebMock).not_to have_synced_a_profile
      end
    end

    context "with a disconnected installation" do
      it "doesn't sync" do
        installation = create(:installation)

        queue_sync installation
        run_queue

        expect(WebMock).not_to have_synced_a_profile
      end
    end

    def queue_sync(*installations)
      BulkSync.new(
        integration_id: :net_suite,
        installations: Installation.where(id: installations)
      ).sync
    end

    def run_queue
      Delayed::Worker.new.work_off

      last_job = Delayed::Job.last
      if last_job
        raise last_job.last_error
      end
    end

    def have_synced_a_profile
      have_requested(
        :post,
        "https://api.cloud-elements.com/elements/api-v2/hubs/erp/employees"
      )
    end
  end
end
