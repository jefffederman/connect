module NetSuite
  class Export
    def self.perform(**args)
      new(args).perform
    end

    def initialize(normalizer:, namely_profiles:, net_suite:)
      @normalizer = normalizer
      @namely_profiles = namely_profiles
      @net_suite = net_suite
    end

    def perform
      namely_profiles.map do |profile|
        export(profile)
      end
    end

    protected

    attr_reader :namely_profiles

    private

    def export(profile)
      Employee.new(
        profile,
        normalizer: @normalizer,
        net_suite: @net_suite
      ).export
    end

    class Employee
      def initialize(profile, normalizer:, net_suite:)
        @normalizer = normalizer
        @profile = profile
        @net_suite = net_suite
      end

      def export
        if persisted?
          update
        else
          create
        end
      end

      private

      def persisted?
        id.present?
      end

      def update
        request(updated: true) do
          @net_suite.update_employee(id.to_s, attributes)
        end
      end

      def create
        request(updated: false) do
          response = @net_suite.create_employee(attributes)
          @profile.update(netsuite_id: response["internalId"])
          response
        end
      end

      def id
        @profile["netsuite_id"].to_s
      end

      def attributes
        @normalizer.export(@profile)
      end

      def request(updated:)
        yield
        Result.new(
          success: true,
          error: nil,
          updated: updated,
          profile: @profile
        )
      rescue NetSuite::ApiError => exception
        Result.new(
          success: false,
          error: exception.to_s,
          updated: updated,
          profile: @profile
        )
      end
    end

    class Result
      def initialize(success:, error:, updated:, profile:)
        @success = success
        @error = error
        @updated = updated
        @profile = profile
      end

      attr_reader :error
      delegate :email, :name, to: :profile

      def profile_id
        @profile.id
      end

      def success?
        @success == true
      end

      def updated?
        @updated
      end

      protected

      attr_reader :profile
    end

    private_constant :Result
  end
end
