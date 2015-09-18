module Features
  def stub_net_suite_subsidiaries(status:, body:)
    stub_request(
      :get,
      "https://api.cloud-elements.com/" \
        "elements/api-v2/hubs/erp/lookups/subsidiary"
    ).to_return(status: status, body: JSON.dump(body))
  end

  def stub_net_suite_fields
    net_suite_employee =
      File.read("spec/fixtures/api_responses/net_suite_employee.json")
    stub_request(
      :get,
      %r{.*/elements/api-v2/hubs/erp/employees\?.*}
    ).to_return(status: 200, body: net_suite_employee)
  end
end
