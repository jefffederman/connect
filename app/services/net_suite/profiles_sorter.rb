module NetSuite
  class ProfilesSorter
    def initialize(profiles:)
      @profiles = profiles
    end

    def call
      profiles.group_by do |profile|
        ReportTo.for(profile).guid
      end.sort do |grouped|
        grouped[1].size
      end.flat_map do |sorted|
        sorted[1]
      end
    end

    private

    class ReportTo
      include Comparable

      def self.for(profile)
        reports_to = Array(profile.reports_to)
        new(report_to: reports_to.first || {id: 0})
      end

      attr_reader :report_to, :guid
      def initialize(report_to:)
        @report_to = report_to
        @guid = report_to.fetch(:id)
      end

      def <=>(other_profile)
        guid <=> other_profile.guid
      end
    end

    attr_reader :profiles
  end
end
