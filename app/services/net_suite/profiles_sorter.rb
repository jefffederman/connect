require 'pqueue'

module NetSuite
  class DepthAndProfile < Struct.new(:depth, :profile); end

  class ProfilesSorter
    def initialize(profiles:)
      @profiles = profiles
      @queue = PQueue.new() { |a,b| b.depth < a.depth }
    end

    def call
      queue.clear

      profiles.each do |p|
        depth = find_depth(p)
        tuple = DepthAndProfile.new(depth, p)

        queue.push(tuple)
      end

      build_profiles_with_supervisor_id(queue.to_a)
    end

    private

    attr_reader :queue

    def mapped_profiles
      @mapped_profiles ||= profiles.each_with_object({}) do |p, hash|
        hash[p.id] = p
      end
    end

    def build_profiles_with_supervisor_id(sorted)
      sorted.map do |tuple|
        ProfileWithSupervisorId.new(
          profile: tuple.profile,
          reports_to: find_reports_to_profile(tuple.profile)
        )
      end
    end

    def find_reports_to_profile(sorted_profile)
      mapped_profiles[ ReportTo.for(sorted_profile).id ]
    end

    def find_depth(profile, depth = 1)
      report_to = ReportTo.for(profile)

      if report_to.id.present?
        depth += 1
        find_depth(mapped_profiles[report_to.id], depth)
      else
        depth
      end
    end

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
          nil
        end

        def netsuite_id
          nil
        end
      end
    end

    attr_reader :profiles
  end
end
