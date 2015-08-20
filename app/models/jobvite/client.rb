module Jobvite
  class Client
    class Error < StandardError; end

    def self.recent_hires(connection)
      new(connection).recent_hires
    end

    def initialize(connection)
      @connection = connection
    end

    def recent_hires
      CandidatePage.all(connection).flat_map(&:candidates)
    end

    private

    attr_reader :connection

    class CandidatePage
      delegate :installation, to: :connection

      attr_reader :response_code

      def self.all(connection)
        page = new(connection: connection, start: 1)
        Enumerator.new do |yielder|
          while page
            yielder.yield page
            page = page.next
          end
        end
      end

      def initialize(connection:, start: 1)
        @connection = connection
        @start = start
      end

      def candidates
        process_errors
        json_response.fetch("candidates", {}).map { |hash| Candidate.new(hash) }
      end

      def next
        unless last_page?
          self.class.new(
            connection: connection,
            start: next_page_start,
          )
        end
      end

      private

      attr_reader :connection, :start

      def invalid_secret_key
        json_response.select do |key, value|
          key == "status" && value == "INVALID_KEY_SECRET"
        end
      end

      def json_response
        @json_response ||= JSON.parse(RestClient.get(url))
      end

      def process_errors
        raise_on_errors_message
        raise_on_authenticaton_error
      end

      def raise_on_errors_message
        if json_response.has_key?("errors")
          raise Error, json_response["errors"]["messages"].to_sentence
        end
      end

      def raise_on_authenticaton_error
        if invalid_secret_key.present?
          exception = Unauthorized.new(json_response["responseMessage"])
          installation.send_connection_notification(
            integration_id: "jobvite",
            message: exception.message
          )
          raise exception
        end
      end

      def url
        "https://api.jobvite.com/api/v2/candidate?#{jobvite_compatible_query}"
      end

      def jobvite_compatible_query
        query_params.to_query.gsub("+", "%20")
      end

      def query_params
        {
          api: connection.api_key,
          sc: connection.secret,
          start: start,
          count: number_per_page,
          wflowstate: connection.hired_workflow_state,
        }
      end

      def last_page?
        json_response.fetch("total", 0) < next_page_start
      end

      def next_page_start
        start + number_per_page
      end

      def number_per_page
        50
      end
    end
    private_constant :CandidatePage
  end
end
