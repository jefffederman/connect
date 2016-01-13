module NetSuite
  class ProfilesSorter
    def initialize(profiles:)
      @profiles = profiles
    end

    def call
      profiles.reduce([]) do |sorted_profiles, profile|
        report_to = ReportTo.for(profile)
        sorted_profiles.take_while do |p|
          p.id != report_to.id
        end + [profile] + sorted_profiles.drop_while do |p|
          p.id != report_to.id
        end
      end.reverse
    end

    private

    class ReportTo
      def self.for(profile)
        if profile.respond_to? :reports_to
          new(report_to: Array(profile.reports_to).first || {id: 0})
        else
          new(report_to: {id: 0})
        end
      end

      attr_reader :report_to, :id
      def initialize(report_to:)
        @report_to = report_to
        @id = report_to.fetch(:id)
      end
    end

    attr_reader :profiles
  end
end
