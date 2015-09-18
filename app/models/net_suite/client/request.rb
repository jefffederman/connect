module NetSuite
  class Client
    class Request
      BASE_URL = "https://api.cloud-elements.com/elements/api-v2"

      def initialize(element_secret:, organization_secret:, user_secret:)
        @element_secret = element_secret
        @organization_secret = organization_secret
        @user_secret = user_secret
      end

      def submit_json(method, path, data)
        translate_response do
          RestClient.public_send(
            method,
            url(path),
            data.to_json,
            authorization: authorization,
            content_type: "application/json"
          )
        end
      end

      def get_json(path)
        translate_response do
          RestClient.get(
            url(path),
            authorization: authorization,
            content_type: "application/json"
          )
        end
      end

      private

      def translate_response
        response = yield
        if response.present?
          JSON.parse(response)
        end
      rescue RestClient::Unauthorized => exception
        raise Unauthorized, exception.message
      rescue RestClient::Exception => exception
        Raygun.track_exception(exception)
        Rails.logger.error(exception)
        raise NetSuite::ApiError, exception, exception.backtrace
      end

      def url(path)
        "#{BASE_URL}#{path}"
      end

      def authorization
        secrets.
          compact.
          map { |name, secret| [name, secret].join(" ") }.
          join(", ")
      end

      def secrets
        {
          "User" => user_secret,
          "Organization" => organization_secret,
          "Element" => element_secret
        }
      end

      attr_reader :element_secret, :organization_secret, :user_secret
    end
  end
end
