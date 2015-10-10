require "rails_helper"

describe NetSuite::Authentication do
  describe "#update" do
    context "with valid information" do
      it "updates the connection from the response" do
        client = stub_client { { "id" => "abc", "token" => "def" } }
        form_attributes = valid_form_attributes
        connection = stub_connection
        form = NetSuite::Authentication.new(
          connection: connection,
          client: client
        )

        result = form.update(form_attributes)

        expect(result).to eq(true)
        expect(connection).to have_received(:update!).with(
          instance_id: "abc",
          authorization: "def"
        )
        expect(client).
          to have_received(:create_instance).with(form)
      end
    end

    context "with invalid fields" do
      it "adds validation messages" do
        client = stub_client { {} }
        connection = stub_connection
        form = NetSuite::Authentication.new(
          connection: connection,
          client: client
        )

        result = form.update({})

        expect(result).to eq(false)
        expect(connection).not_to have_received(:update!)
        expect(client).not_to have_received(:create_instance)
        expect(form.errors.full_messages).to match_array([
          "Account can't be blank",
          "Email can't be blank",
          "Password can't be blank"
        ])
      end
    end

    context "when the server form fails" do
      it "adds validation errors from the server" do
        exception = double(
          :exception,
          response: { "message" => "oops" }.to_json,
          http_code: 499
        )
        client = stub_client { raise NetSuite::ApiError, exception }
        connection = stub_connection
        form = NetSuite::Authentication.new(
          connection: connection,
          client: client
        )

        result = form.update(valid_form_attributes)

        expect(result).to eq(false)
        expect(connection).not_to have_received(:update!)
        expect(form.errors.full_messages).
          to eq(%w(oops))
      end
    end
  end

  def valid_form_attributes
    { account_id: "a", email: "b", password: "c" }
  end

  def stub_connection
    double(NetSuite::Connection).tap do |connection|
      allow(connection).to receive(:update!)
      allow(connection).to receive(:installation)
    end
  end

  def stub_client(&block)
    double(NetSuite::Client).tap do |client|
      allow(client).to receive(:create_instance, &block)
    end
  end
end
