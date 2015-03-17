require "rails_helper"

describe Jobvite::Import do
  describe "#import" do
    context "with a connected Jobvite::Connection" do
      it "passes hired Jobvite candidates to the NamelyImporter and set the status" do
        user = double(
          "user",
          jobvite_connection: double("jobvite_connection", connected?: true),
          namely_connection: double("Namely::Connection"),
        )
        recent_hires = [double("hire")]
        jobvite_client = double("jobvite_client", recent_hires: recent_hires)
        expected_status = double("status")
        namely_importer = double(
          "NamelyImporter",
          import: expected_status,
        )
        import = described_class.new(
          user,
          jobvite_client: jobvite_client,
          namely_importer: namely_importer,
        )

        status = import.import

        expect(status).to eq expected_status
        expect(jobvite_client).to have_received(:recent_hires).
          with(user.jobvite_connection)
        expect(namely_importer).to have_received(:import).with(
          recent_imports: recent_hires,
          namely_connection: user.namely_connection,
          attribute_mapper: instance_of(Jobvite::AttributeMapper),
        )
      end
    end

    context "when the Jobvite API request fails" do
      it "sets the status to the Jobvite error message" do
        user = double(
          "user",
          jobvite_connection: double("jobvite_connection", connected?: true),
          namely_connection: double("Namely::Connection"),
        )
        jobvite_client = double("jobvite_client")
        allow(jobvite_client).
          to receive(:recent_hires).
          and_raise(Jobvite::Client::Error, "Everything is broken")
        namely_importer = double("NamelyImporter")
        import = described_class.new(
          user,
          jobvite_client: jobvite_client,
          namely_importer: namely_importer,
        )

        status = import.import

        expect(status).to eq t(
          "status.jobvite_error",
          message: "Everything is broken",
        )
      end
    end

    context "when the Namely API request fails" do
      it "sets the status to the Namely error message" do
        user = double(
          "user",
          jobvite_connection: double("jobvite_connection", connected?: true),
          namely_connection: double("Namely::Connection"),
        )
        recent_hires = [double("hire")]
        jobvite_client = double("jobvite_client", recent_hires: recent_hires)
        namely_importer = double("NamelyImporter")
        allow(namely_importer).
          to receive(:import).
          and_raise(Namely::FailedRequestError, "A Namely error")
        import = described_class.new(
          user,
          jobvite_client: jobvite_client,
          namely_importer: namely_importer,
        )

        status = import.import

        expect(status).to eq t(
          "status.namely_error",
          message: "A Namely error",
        )
      end
    end

    context "with a disconnected Jobvite::Connection" do
      it "does nothing and sets an appropriate status" do
        user = double(
          "user",
          jobvite_connection: double("jobvite_connection", connected?: false),
          namely_connection: double("Namely::Connection"),
        )
        import = described_class.new(user)
        status = nil

        expect { status = import.import }.not_to raise_exception
        expect(status).to eq t("status.not_connected")
      end
    end
  end
end
