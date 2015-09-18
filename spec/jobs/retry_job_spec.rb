require "rails_helper"

describe RetryJob do
  it "runs a retry" do
    sync_summary = create(:sync_summary)
    allow(sync_summary).to receive(:retry).and_return([])

    RetryJob.perform_now(sync_summary)

    expect(sync_summary).to have_received(:retry)
  end

  it "notifies of results" do
    sync_summary = create(:sync_summary)
    allow(Notifier).to receive(:execute)

    RetryJob.perform_now(sync_summary)

    expect(Notifier).to have_received(:execute).with(sync_summary.connection)
  end
end
