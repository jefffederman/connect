require "rails_helper"

describe NetSuite::ApiError do
  describe "#message" do
    context "with a JSON message" do
      it "returns the encoded message" do
        message = "Error"
        exception = double(
          :exception,
          response: { "providerMessage" => message }.to_json,
          http_code: 499
        )
        error = NetSuite::ApiError.new(exception)

        result = error.message

        expect(result).to eq(message)
      end
    end

    context "with a JSON provider message" do
      it "returns the encoded message" do
        message = "Error"
        exception = double(
          :exception,
          response: { "message" => message }.to_json,
          http_code: 499
        )
        error = NetSuite::ApiError.new(exception)

        result = error.message

        expect(result).to eq(message)
      end
    end

    context "with JSON without a message" do
      it "returns a default message" do
        exception = double(:exception, response: {}.to_json, http_code: 499)
        error = NetSuite::ApiError.new(exception)

        result = error.message

        expect(result).to eq("Unknown error")
      end
    end

    context "with an empty response" do
      it "returns a default message" do
        exception = double(:exception, response: nil, http_code: 499)
        error = NetSuite::ApiError.new(exception)

        result = error.message

        expect(result).to eq("Unknown error")
      end
    end
  end
end
