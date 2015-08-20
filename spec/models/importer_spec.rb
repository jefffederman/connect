require "rails_helper"

describe Importer do
  describe "#import" do
    context "with a connected" do
      it "passes hired candidates to the NamelyImporter and set the status" do
        namely_connection = double("Namely::Connection")
        connection = double("connection", connected?: true)
        recent_hires = [double("hire")]
        client = double("client", recent_hires: recent_hires)
        expected_status = double("status")
        namely_importer = double(
          "NamelyImporter",
          import: expected_status,
        )
        import = described_class.new(
          client: client,
          connection: connection,
          namely_importer: namely_importer,
          namely_connection: namely_connection,
        )

        status = import.import

        expect(status).to eq expected_status
        expect(client).to have_received(:recent_hires)
        expect(namely_importer).to have_received(:import).with(recent_hires)
      end
    end

    context "when the request fails" do
      it "sets the status to error message" do
        namely_connection = double("Namely::Connection")
        connection = double("connection", connected?: true)
        client = double("client", class: Icims::Client)
        allow(client).
          to receive(:recent_hires).
          and_raise(Icims::Client::Error, "Everything is broken")
        namely_importer = double("NamelyImporter")
        import = described_class.new(
          client: client,
          connection: connection,
          namely_importer: namely_importer,
          namely_connection: namely_connection
        )

        status = import.import

        expect(status.error).to eq(
          t("status.client_error",message: "Everything is broken")
        )
      end
    end

    context "when the Namely API request fails" do
      it "sets the status to the Namely error message" do
        namely_connection = double("Namely::Connection")
        recent_hires = [double("hire")]
        connection = double("connection", connected?: true)
        client = double(
          "client",
          class: Icims::Client,
          recent_hires: recent_hires,
        )
        namely_importer = double("NamelyImporter")
        allow(namely_importer).
          to receive(:import).
          and_raise(Namely::FailedRequestError, "A Namely error")
        import = described_class.new(
          client: client,
          connection: connection,
          namely_importer: namely_importer,
          namely_connection: namely_connection
        )

        status = import.import

        expect(status.error).to eq(
          t("status.namely_error", message: "A Namely error")
        )
      end
    end

    context "with a disconnected" do
      it "does nothing and sets an appropriate status" do
        namely_connection = double("Namely::Connection")
        importer = described_class.new(
          client: double("client"),
          connection: double("connection", connected?: false),
          namely_importer: double("namely_importer"),
          namely_connection: namely_connection
        )
        status = nil

        expect { status = importer.import }.not_to raise_exception
        expect(status.error).to eq(t("status.not_connected"))
      end
    end
  end
end
