module NetSuite
  class ProfilesSorter
    def initialize(profiles:)
      @profiles = profiles
    end

    def call
      profiles.sort_by do |profile|
        ReportTo.for(profile) <=> profile.guid
      end
    end

    private

    class ReportTo
      include Comparable

      def self.for(profile)
        unless profile.reports_to.empty?
          new(guid: profile.reports_to.first.fetch(:id, -1))
        else
          new(guid: -1)
        end
      end

      attr_reader :guid
      def initialize(guid:)
        @guid = guid
      end

      def <=>(other_guid)
        guid <=> other_guid
      end

      private

      attr_reader :guid
    end

    attr_reader :profiles
  end
end
