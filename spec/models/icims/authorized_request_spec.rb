require "rails_helper"

describe Icims::AuthorizedRequest do
  describe "#headers" do
    it "request has the necessary information" do
      expect(build_authorized_request.headers.keys).
        to match_array [
          "content-type",
          "host",
          "x-icims-content-sha256",
          "x-icims-date",
        ]
    end

    it "sends a header with a hash of its payload" do
      request = build_request
      authorized_request = build_authorized_request(request: request)
      expect(authorized_request.headers["x-icims-content-sha256"]).
        to eq OpenSSL::Digest::SHA256.new(request.payload).hexdigest
    end

    it "sends a header with formatted date time of its request" do
      Timecop.freeze(Time.current) do
        expect(build_authorized_request.headers["x-icims-date"]).
          to eq Time.current.iso8601
      end
    end
  end

  describe "#canonical_request" do
    it "returns a string of several attributes on the request" do
      request = RestClient::Request.new(
        method: :get,
        url: "https://api.icims.com/or-ya-know?fields=stuff",
        headers: {},
      )

      expect(build_authorized_request(request: request).canonical_request).
        to eq canonical_request(request)
    end
  end

  describe "#string_to_sign" do
    it "returns a string to sign" do
      authorized_request = build_authorized_request
      Timecop.freeze do
        signable_string = [
          "x-icims-v1-hmac-sha256",
          "#{Time.current.iso8601}",
          "#{OpenSSL::Digest::SHA256.new(
            authorized_request.canonical_request)
          }",
        ].join("\n")

        expect(authorized_request.string_to_sign).to eq signable_string
      end
    end
  end

  describe "#signature" do
    it "returns a signature" do
      connection = build_connection
      request = build_authorized_request(connection: connection)
      signed_string = OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest::SHA256.new,
        connection.key,
        request.string_to_sign,
      )

      expect(request.signature).to eq signed_string
    end
  end

  describe "#authorization_header" do
    it "returns the value for the 'Authorization' header" do
      connection = build_connection
      request = build_authorized_request(connection: connection)
      header = [
        "x-icims-v1-hmac-sha256 user=#{connection.username}",
        "signedheaders=content-type;host;x-icims-content-sha256;x-icims-date",
        "signature=#{request.signature}",
      ].join(", ")

      expect(request.authorization_header).to eq header
    end
  end

  describe "#execute" do
    it "sends the request with the appropriate authorization header" do
      request = stub_request(
        :post,
        build_request.url,
      ).with(
        headers: {
          "Authorization" => build_authorized_request.authorization_header,
        }
      )

      build_authorized_request.execute

      expect(request).to have_been_requested
    end

    context "an authentication error is returned" do
      it "sends an invalid authentication message" do
        user = build(:user)
        installation = build(:installation, users: [user])
        connection = build_connection(installation: installation)
        request = build_authorized_request(connection: connection)
        stub_request(
          :post,
          build_request.url,
        ).with(
          headers: {
            "Authorization" => request.authorization_header,
          }
        ).to_return(status: 401, body: errors.to_json)

        mail = double(ConnectionMailer, deliver: true)
        exception = Unauthorized.new("401 Unauthorized")
        allow(ConnectionMailer).
          to receive(:authentication_notification).
          with(
            email: user.email,
            integration_id: "icims",
            message: exception.message,
          ).
          and_return(mail)

        expect { request.execute }.to raise_error(Unauthorized)
        expect(mail).to have_received(:deliver)
      end
    end
  end

  def build_authorized_request(
    request: build_request,
    connection: build_connection
  )
    described_class.new(connection: connection, request: request)
  end

  def build_connection(*attributes)
    build(:icims_connection, :connected, *attributes)
  end

  def errors
    {
      "errors" => [
        {
          "errorCode": 9,
          "errorMessage": "Authentication credentials invalid"
        }
      ]
    }
  end

  def build_request
    RestClient::Request.new(
      method: :post,
      url: "https://api.icims.com/or-whatever",
      headers: {},
      data: {}.to_json,
    )
  end

  def canonical_request(request)
    headers = build_authorized_request(request: request).headers
    <<-REQUEST.strip_heredoc.strip
      #{request.method.upcase}
      /or-ya-know
      fields=stuff
      content-type:application/json
      host:api.icims.com
      x-icims-content-sha256:#{headers["x-icims-content-sha256"]}
      x-icims-date:#{headers["x-icims-date"]}

      content-type;host;x-icims-content-sha256;x-icims-date
    REQUEST
  end
end
