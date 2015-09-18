require "rails_helper"

describe NetSuite::EmployeeFieldsLoader do
  describe "#load_profile_fields" do
    it "does not include custom fields if environment opts out" do
      ClimateControl.modify(NET_SUITE_CUSTOM_FIELDS_ENABLED: "false") do
        stubbed_employee_data = [
          stub_employee_data(
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

        stub_employee_query(stubbed_employee_data)
        loader = loader_for_request
        ids = loader.load_profile_fields.map(&:id)

        expect(ids).not_to include("custom:5796:custentity_rss_linkedin")
      end
    end

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
          internal: true,
          internalId: "-5",
          externalId: nil,
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

      stub_employee_query(stubbed_employee_data)

      loader = loader_for_request

      fields = stub_blacklist("internalId,externalId") do
        loader.load_profile_fields
      end

      labels = fields.map(&:label)
      types = fields.map(&:type)
      ids = fields.map(&:id)

      expect(ids).to match_array(%w(
        expenseLimit
        firstName
        hireDate
        internal
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
        "Internal",
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

  def stub_employee_query(employee_data)
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
      body: employee_data.to_json,
      status: 200
    )
  end

  def loader_for_request
    request = NetSuite::Client.new(
      element_secret: "element-secret",
      organization_secret: "org-secret",
      user_secret: "user-secret",
    ).request

    described_class.new(request: request)
  end

  def stub_blacklist(fields, &block)
    ClimateControl.modify(NET_SUITE_FIELD_BLACKLIST: fields, &block)
  end
end
