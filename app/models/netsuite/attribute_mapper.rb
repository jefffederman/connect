module Netsuite
  class AttributeMapper
    def call(netsuite_employee)
      {
        first_name: netsuite_employee["first_name"],
        last_name: netsuite_employee["last_name"],
        email: netsuite_employee["email"],
        user_status: netsuite_status[netsuite_employee["is_inactive"]],
        gender: netsuite_employee["gender"],
        namely_identifier_field => identifier(netsuite_employee),
      }.select { |key, value| value.present? }
    end

    def namely_identifier_field
      :netsuite_id
    end

    def identifier(netsuite_employee)
      netsuite_employee["internal_id"]
    end

    def netsuite_status
      { "false" => "active", "true" => "inactive" }
    end
  end
end
