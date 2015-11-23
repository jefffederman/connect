require "rails_helper"

feature "user exports to net suite" do
  scenario "successfully" do
    user = create(:user)
    cloud_elements = "https://api.cloud-elements.com/elements/api-v2/hubs/erp"
    subsidiary_url = "#{cloud_elements}/lookups/subsidiary"
    subsidiary_id = 52

    employee_json =
      File.read("spec/fixtures/api_responses/net_suite_employee.json")

    stub_request(:get, %r{#{cloud_elements}/employees\?pageSize=5}).
      to_return(status: 200, body: employee_json)

    stub_request(
      :get,
      "#{cloud_elements}/employees?where=subsidiary%3D#{subsidiary_id}"
    ).to_return(
      body: [
        {internalId: "1234", firstName: "TT"},
      ].to_json
    )
    stub_namely_data("/profiles", "profiles_with_net_suite_fields")
    stub_request(:put, %r{.*api/v1/profiles/.*}).to_return(status: 200)
    stub_request(:post, "#{cloud_elements}/employees").
      with(body: /Sally/).
      to_return(status: 200, body: { "internalId" => "123" }.to_json)
    stub_request(:patch, "#{cloud_elements}/employees/1234").
      with(body: /Tina/).
      to_return(status: 200, body: { "internalId" => "1234" }.to_json)
    stub_request(:post, "#{cloud_elements}/employees").
      with(body: /Mickey/).
      to_return(status: 400, body: { "message" => "Bad Data" }.to_json)

    stub_namely_fields("fields_with_net_suite")
    stub_request(
      :post,
      "https://api.cloud-elements.com/elements/api-v2/instances"
    ).to_return(status: 200, body: { id: "1", token: "2" }.to_json)
    stub_request(:get, subsidiary_url).
      to_return(status: 200, body: [{ name: "hello", internalId: subsidiary_id }].to_json)

    visit dashboard_path(as: user)

    find(".net-suite-account").click_on t("dashboards.show.connect")

    fill_in("net_suite_authentication_account_id", with: "123xy")
    fill_in("net_suite_authentication_email", with: user.email)
    fill_in("net_suite_authentication_password", with: "abc12z")
    click_button t("helpers.submit.net_suite_connection.update")

    select("hello", from: "net_suite_connection_subsidiary_id")
    click_button t("helpers.submit.net_suite_connection.update")

    select "Mobile phone", from: t("integration_fields.phone")
    select "Custom field", from: t("integration_fields.email")
    select "Preferred name", from: "Initials"
    select "LinkedIn URL", from: "Custentity Linkedin Url"
    click_on t("attribute_mappings.edit.save")

    find(".net-suite-account").click_on t("dashboards.show.export_now")

    expect(page).
      to have_content(t("syncs.create.title", integration: t("net_suite.name")))


    expect(WebMock).
      to have_requested(:post, "#{cloud_elements}/employees").
      with(
        body: hash_including(
          email: "sally.secondary@example.com",
          phone: "+46 70 818 12 34",
          title: "CEO",
          addressbookList: {
            addressbook: [
              {
                defaultShipping: true,
                addressbookAddress: {
                  zip: "02108",
                  country: {
                    value: "_unitedStates"
                  },
                  addr2: "Apt 123",
                  addr1: "100 Pruder Street",
                  city: "Boston",
                  addr3: "",
                  addressee: "Sally Smith",
                  attention: "",
                  state: "MA"
                }
              }
            ],
            replaceAll: true
          },
          customFieldList: {
            customField: [
              {
                internalId: "2096",
                scriptId: "custentity_linkedin_url",
                value: "http://example.com/sally"
              }
            ]
          }
        )
      )
  end
end
