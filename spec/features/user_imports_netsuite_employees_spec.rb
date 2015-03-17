require "rails_helper"

feature "User imports netsuite employees" do
  scenario "successfully" do
    user = create(:user)
    stubbed_netsuite_gateway_request
    stubbed_namely_post_request
    stubbed_namely_get_request

    visit dashboard_path(as: user)
    within(".netsuite-import") do
      click_button t("dashboards.show.import_now")
    end

    expect(page).to have_content t(
      "netsuite_imports.create.imported_successfully"
    )
  end

  def api_host
    "%{protocol}://%{subdomain}.namely.com" % {
      protocol: Rails.configuration.namely_api_protocol,
      subdomain: ENV["TEST_NAMELY_SUBDOMAIN"],
    }
  end

  def stubbed_namely_post_request
    stub_request(:post, "#{api_host}/api/v1/profiles").
      to_return(
        status: 200,
        body: File.read("spec/fixtures/api_responses/not_empty_profiles.json")
      )
  end

  def netsuite_employee
    JSON.parse(File.read("spec/fixtures/api_responses/netsuite_employee.json"))
  end

  def stubbed_netsuite_gateway_request
    stub_request(:get, ENV["NETSUITE_GATEWAY_URL"]).
      to_return(body: [netsuite_employee].to_json)
  end

  def stubbed_namely_get_request
    stub_request(:get, "#{api_host}/api/v1/profiles").
      with(
        query: {
          access_token: ENV["TEST_NAMELY_ACCESS_TOKEN"],
          limit: "all",
        }
      ).
      to_return(
        status: 200,
        body: File.read("spec/fixtures/api_responses/empty_profiles.json")
      )
  end
end
