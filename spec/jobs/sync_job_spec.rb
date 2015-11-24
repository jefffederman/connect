require "rails_helper"

describe SyncJob do
  it "notifies of results" do
    connection = double(:connection, lockable?: false)
    allow(Notifier).to receive(:execute)

    SyncJob.perform_now(connection)

    expect(Notifier).to have_received(:execute).with(connection)
  end
end
