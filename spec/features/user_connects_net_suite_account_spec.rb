require "rails_helper"

feature "user connects NetSuite account" do
  scenario "successfully" do
    stub_namely_fields("fields_with_net_suite")
    stub_net_suite_fields
    stub_create_instance(status: 200, body: { id: "123", token: "abcxyz" })
    stub_lookup_subsidiaries(
      status: 200,
      body: [
        { "internalId": "1", "name": "First" },
        { "internalId": "2", "name": "Second" }
      ]
    )

    visit_dashboard

    expect(net_suite).
      to have_text_from("net_suite_connections.description.disconnected_html")
    net_suite.click_link t("dashboards.show.connect")

    submit_net_suite_account_form
    select_net_suite_subsidiary("Second")
    save_attribute_mappings
    expect(net_suite).
      to have_text_from("net_suite_connections.description.connected_html")
  end

  scenario "with bad authentication" do
    stub_create_instance(status: 400, body: { message: "Not good" })

    visit_dashboard

    net_suite.click_link t("dashboards.show.connect")

    submit_net_suite_account_form
    expect(page).to have_content("Not good")
  end

  scenario "with updated credentials" do
    stub_namely_fields("fields_with_net_suite")
    stub_net_suite_fields
    stub_create_instance(status: 200, body: { id: "123", token: "abcxyz" })
    stub_lookup_subsidiaries(
      status: 200,
      body: [{ "internalId": "1", "name": "First" }]
    )

    visit_dashboard
    net_suite.click_link t("dashboards.show.connect")
    submit_net_suite_account_form
    select_net_suite_subsidiary("First")
    save_attribute_mappings

    net_suite.click_link t("dashboards.show.edit")
    submit_net_suite_account_form
    expect(net_suite).
      to have_text_from("net_suite_connections.description.connected_html")
  end

  def visit_dashboard
    user = create(:user)
    visit dashboard_path(as: user)
  end

  def submit_net_suite_account_form
    fill_in field("net_suite_authentication.email"), with: "user@example.com"
    fill_in field("net_suite_authentication.account_id"), with: "12345"
    fill_in field("net_suite_authentication.password"), with: "secret"
    click_button button("net_suite_connection.update")
  end

  def select_net_suite_subsidiary(name)
    select name, from: field("net_suite_connection.subsidiary_id")
    click_button button("net_suite_connection.update")
  end

  def save_attribute_mappings
    click_on t("attribute_mappings.edit.save")
  end

  def stub_create_instance(status:, body:)
    stub_request(
      :post,
      "https://api.cloud-elements.com/elements/api-v2/instances"
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

  def stub_lookup_subsidiaries(status:, body:)
    stub_request(
      :get,
      "https://api.cloud-elements.com/" \
        "elements/api-v2/hubs/erp/lookups/subsidiary"
    ).to_return(status: status, body: JSON.dump(body))
  end

  def net_suite
    page.find(".net-suite-account")
  end

  def have_text_from(key)
    html = t(key)
    text = Capybara.string(html).text
    have_content(text)
  end
end
