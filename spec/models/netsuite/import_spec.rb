require "rails_helper"

describe Netsuite::Import do
  describe "#import" do
    context "with a connected Netsuite::Connection" do
      it "passes employees from NetsuiteGateway to Connect and updates info" do
        user = double(
          "user",
          namely_connection: double("Namely::Connection"),
        )
        netsuite_employee = JSON.parse(
          File.read("spec/fixtures/api_responses/netsuite_employee.json")
        )

        expected_status = double("status")
        namely_importer = double("NamelyImporter", import: expected_status)
        netsuite_import = Netsuite::Import.new(
          user,
          namely_importer: namely_importer,
        )
        allow(netsuite_import).to receive(:netsuite_employees).
          and_return([netsuite_employee])

        status = netsuite_import.import

        expect(status).to eq expected_status
        expect(namely_importer).to have_received(:import).with(
          recent_hires: [netsuite_employee],
          namely_connection: user.namely_connection,
          attribute_mapper: instance_of(Netsuite::AttributeMapper),
        )

        expect(netsuite_import).to have_received(:netsuite_employees)
      end
    end
  end
end
