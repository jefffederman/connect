module NetSuite
  class ProfilesSorter
    def initialize(profiles:)
      @profiles = profiles
    end

    def call
      sorted = profiles.reduce([]) do |sorted_profiles, profile|
        report_to = ReportTo.for(profile)
        sorted_profiles.take_while do |p|
          p.id != report_to.id
        end + [profile] + sorted_profiles.drop_while do |p|
          p.id != report_to.id
        end
      end
      sorted.map do |sorted_profile|
        ProfileWithSupervisorId.new(
          profile: sorted_profile,
          reports_to: sorted.find do |profile|
            ReportTo.for(sorted_profile).id == profile.id
          end
        )
      end.reverse
    end

    private

    class ProfileWithSupervisorId < SimpleDelegator
      def initialize(profile:, reports_to:)
        @reports_to = reports_to
        super(profile)
      end

      def class
        __getobj__.class
      end

      def netsuite_supervisor_id
       reports_to.netsuite_id if reports_to.respond_to? :netsuite_id
      end

      private

      attr_reader :reports_to
    end

    class ReportTo
      def self.for(profile)
        if profile.respond_to? :reports_to
          new(report_to: Array(profile.reports_to).first || NoReportTo.new)
        else
          new(report_to: NoReportTo.new)
        end
      end

      attr_reader :report_to, :id
      def initialize(report_to:)
        @report_to = report_to
        @id = report_to.id
      end

      private

      class NoReportTo
        def id
          0
        end

        def netsuite_id
          0
        end
      end
    end

    attr_reader :profiles
  end
end
