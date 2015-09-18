require "rails_helper"

describe Notifier do
  it "runs the provided block and emails the results" do
    connection = build_stubbed(:net_suite_connection)
    results = double(:results)
    allow(connection).to receive(:sync).and_return(results)
    allow(SyncNotifier).to receive(:deliver)

    Notifier.execute(connection) do
      connection.sync
    end

    expect(connection).to have_received(:sync)
    expect(SyncNotifier).
      to have_received(:deliver).
      with(
        results: results,
        integration_id: connection.integration_id,
        installation: connection.installation
      )
  end

  context "authentication failure" do
    it "traps exception and alerts the user" do
      connection = build_stubbed(:net_suite_connection)
      exception = Unauthorized.new("An error message")
      allow(connection).to receive(:sync).and_raise(exception)
      allow(UnauthorizedNotifier).to receive(:deliver)

      Notifier.execute(connection) do
        connection.sync
      end

      expect(UnauthorizedNotifier).to have_received(:deliver).
        with(connection: connection, exception: exception)
    end
  end
end
