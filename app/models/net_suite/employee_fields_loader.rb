module NetSuite
  class EmployeeFieldsLoader
    EMPLOYEE_LIMIT = 5

    def initialize(request:)
      @request = request
    end

    def load_profile_fields
      employees = request.get_json(
        "#{NetSuite::Client::EMPLOYEE_REQUEST}?pageSize=#{EMPLOYEE_LIMIT}"
      )

      employees.
        flat_map { |employee| profile_fields_from_employee_hash(employee) }.
        uniq(&:id).
        reject { |field| blacklist.include?(field.id) }
    end

    private

    def blacklist
      ENV.fetch("NET_SUITE_FIELD_BLACKLIST", "").split(",")
    end

    def profile_fields_from_employee_hash(employee)
      standard_fields(employee) + custom_fields(employee)
    end

    def standard_fields(employee)
      employee.except("customFieldList").map do |id, value|
        NetSuite::EmployeeField.new(id: id, name: id, value: value)
      end
    end

    def custom_fields(employee)
      if ENV["NET_SUITE_CUSTOM_FIELDS_ENABLED"] == "true"
        employee.
          fetch("customFieldList", {}).
          fetch("customField", []).
          map { |field| custom_field(field) }
      else
        []
      end
    end

    def custom_field(field)
      NetSuite::EmployeeField.new(
        id: ["custom", field["internalId"], field["scriptId"]].join(":"),
        name: field["scriptId"],
        value: field["value"]
      )
    end

    attr_reader :request
  end
end
