require "rails_helper"

describe NetSuite::EmployeeFieldsLoader do
  describe "#retrieve_fields" do
    it "gets a currest list of NetSuite employee profile fields" do
      stubbed_employee_data = [
        stub_employee_data(
          firstName: "Channing"
        ),
        stub_employee_data(
          expenseLimit: 100,
          firstName: "Ralph",
          hireDate: Time.now.to_i,
          isSalesRep: false,
          lastName: "Bot",
          officePhone: "212-555-1212",
          subsidiary: {},
          customFieldList: {
            customField: [
              {
                "internalId": "5796",
                "scriptId": "custentity_rss_linkedin",
                "value": "http://example.com/linkedin"
              }
            ]
          },
        )
      ]

      stub_request(
        :get,
        "https://api.cloud-elements.com/elements/api-v2" \
        "/hubs/erp/employees?pageSize=5"
      ).with(
        headers: {
          "Authorization" => "User user-secret, " \
          "Organization org-secret, " \
          "Element element-secret",
          "Content-Type" => "application/json"
        }
      ).to_return(
        body: stubbed_employee_data.to_json,
        status: 200
      )

      request = NetSuite::Client.new(
        element_secret: "element-secret",
        organization_secret: "org-secret",
        user_secret: "user-secret",
      ).request

      loader = described_class.new(request: request)
      fields = loader.load_profile_fields
      labels = fields.map(&:label)
      types = fields.map(&:type)
      ids = fields.map(&:id)

      expect(ids).to match_array(%w(
        expenseLimit
        firstName
        hireDate
        isSalesRep
        lastName
        officePhone
        subsidiary
        custom:5796:custentity_rss_linkedin
      ))
      expect(types.uniq).to match_array(%w(boolean date fixnum object text))
      expect(labels).to match_array([
        "Expense Limit",
        "First Name",
        "Hire Date",
        "Is Sales Rep",
        "Last Name",
        "Office Phone",
        "Subsidiary",
        "Custentity Rss Linkedin"
      ])
    end
  end

  def stub_employee_data(options = {})
    {
      expenseLimit: 0,
      firstName: "First",
      hireDate: Time.now.to_i,
      isSalesRep: false,
      lastName: "Last",
      officePhone: "919-555-0000",
      subsidiary: {},
    }.merge(options).deep_stringify_keys
  end
end
