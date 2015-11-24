module NetSuite
  # Finds matching NetSuite employee and Namely profile pairs based on either a
  # netsuite_id or provided fields to match on (names or emails for example).
  class Matcher
    # @param fields [Array} List of Netsuite fields to match objects
    # @param profiles [Array] Namely profile list
    # @param employees [Array] Netsuite employee list
    def initialize(mapper:, fields:, profiles:, employees:)
      @fields = fields
      @employees = employees
      @profiles = profiles
      @mapper = mapper
      @employees_by_id = Hash[@employees.map { |e| [e["internalId"], e] }]
    end

    # Returns matched pairs of profiles
    # @return [Array] An array of hashes containing the profiles that were matched together
    def results
      @results ||= profiles.map do |profile|
        namely_employee = normalize(profile)
        employee = match_employee(profile, namely_employee)
        Result.new(profile, namely_employee, employee)
      end
    end

    class Result < Struct.new(:profile, :namely_employee, :netsuite_employee)
      def matched?
        netsuite_employee.present?
      end
    end

    private

    attr_reader :employees, :profiles, :employees_by_id, :mapper, :fields

    def match_employee(profile, namely_employee)
      employee = nil
      if profile["netsuite_id"].present? && @employees_by_id.has_key?(profile["netsuite_id"].to_s)
        return employees_by_id[profile["netsuite_id"].to_s]
      else
        return employees.find do |employee|
          fields.all? { |field| employee[field] == namely_employee[field] }
        end
      end
    end

    def normalize(profile)
      mapper.export(profile)
    end
  end
end

