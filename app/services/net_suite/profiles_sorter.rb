module NetSuite
  class ProfilesSorter

    def initialize(profiles:)
      @profiles = profiles
    end

    def call
      profiles.sort_by do |profile|
        profile.reports_to.first.fetch(:id) <=> profile.guid
      end
    end

    private

    attr_reader :profiles
  end
end
