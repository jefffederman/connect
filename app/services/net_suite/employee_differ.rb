module NetSuite
  # EmployeeDiffer takes a Namely Profile and NetSuite Employee and attempts
  # to figure out if there is a difference between the 2 based on simple
  # heuristics
  class EmployeeDiffer
    # @param namely_employee An object representing a namely profile
    # @param netsuite_employee An object representing an employee record on NetSuite
    # @param mapper [AttributeMapper] An attribute mapper to perform the correct diffs against
    def initialize(namely_employee:, netsuite_employee:)
      @namely_employee = namely_employee
      @netsuite_employee = netsuite_employee
    end

    # Performs a simple check to see if all applicable fields from Netsuite
    # match a Namely profile.
    #
    # @return [Boolean] True if any field mismatches, false otherwise
    def different?
      netsuite_export = normalize_hash(namely_employee)
      normalized_netsuite_employee = normalize_hash(netsuite_employee)

      !netsuite_export.all? do |key, value|
        netsuite_value = normalized_netsuite_employee[key]
        next true unless netsuite_value.present?

        if value == netsuite_value
          true
        else
          Rails.logger.info "Difference: #{value}, Netsuite: #{netsuite_value}, ID: #{normalized_netsuite_employee["internalID"]}"
          false
        end
      end
    end

    private

    attr_reader :namely_employee, :netsuite_employee

    def normalize_hash(hash)
      hash.stringify_keys.each_with_object({}) do |(key, value), h|
        h[key] = normalize_value(value)
      end
    end

    def normalize_value(value)
      case value
      when String
        value.strip.downcase
      else
        value
      end
    end
  end
end
