module NetSuite
  class Client
    class Result
      include Enumerable

      def initialize(success, response)
        @success = success
        @response = response
      end

      def success?
        @success
      end

      def [](attribute)
        json[attribute.to_s]
      end

      def each(&block)
        json.each(&block)
      end

      private

      def json
        @json ||= JSON.parse(@response)
      end
    end
  end
end
