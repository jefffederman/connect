require "rails_helper"

describe BulkSync do
  include Features

  describe ".sync" do
    it "runs without error" do
      expect { BulkSync.sync(:net_suite) }.not_to raise_error
    end
  end

  describe "#sync" do
    context "with a fully connected installation" do
      it "enqueues background sync jobs" do
        connections = create_pair(:net_suite_connection, :ready)
        allow(SyncJob).to receive(:perform_later)

        queue_sync connections.map(&:installation)

        expect(SyncJob).to have_received(:perform_later).twice
        expect(SyncJob).to have_received(:perform_later).
          with(connections.first).
          once
        expect(SyncJob).to have_received(:perform_later).
          with(connections.last).
          once
      end
    end

    context "with an installation without a mapped Namely field" do
      it "doesn't sync" do
        connection = create(
          :net_suite_connection,
          :connected,
          found_namely_field: false
        )

        queue_sync connection.installation

        expect(WebMock).not_to have_synced_a_profile
      end
    end

    context "with a disconnected installation" do
      it "doesn't sync" do
        installation = create(:installation)

        queue_sync installation

        expect(WebMock).not_to have_synced_a_profile
      end
    end

    def queue_sync(*installations)
      BulkSync.new(
        integration_id: :net_suite,
        installations: Installation.where(id: installations.flatten)
      ).sync
    end

    def have_synced_a_profile
      have_requested(
        :post,
        "https://api.cloud-elements.com/elements/api-v2/hubs/erp/employees"
      )
    end
  end
end
