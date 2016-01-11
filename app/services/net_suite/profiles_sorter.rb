module NetSuite
  class ProfilesSorter
    def initialize(profiles:)
      @profiles = profiles
    end

    def call
      profiles.sort_by do |profile|
        ReportTo.for(profile) <=> profile
      end
    end

    private

    class ReportTo
      include Comparable

      def self.for(profile)
        if profile.respond_to? :reports_to
          unless Array(profile.reports_to).empty?
            new(report_to: profile.reports_to.first)
          end
        end
      end

      attr_reader :report_to, :guid
      def initialize(report_to:)
        @report_to = report_to
        @guid = report_to.fetch(:id, -1)
      end

      def <=>(other_profile)
        guid <=> other_profile.guid
      end
    end

    attr_reader :profiles
  end
end
