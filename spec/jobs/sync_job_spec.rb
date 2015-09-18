require "rails_helper"

describe SyncJob do
  it "runs a sync" do
    connection = build_stubbed(:net_suite_connection)
    allow(connection).to receive(:sync).and_return([])

    SyncJob.perform_now(connection)

    expect(connection).to have_received(:sync)
  end

  it "notifies of results" do
    connection = double(:connection)
    allow(Notifier).to receive(:execute)

    SyncJob.perform_now(connection)

    expect(Notifier).to have_received(:execute).with(connection)
  end
end
