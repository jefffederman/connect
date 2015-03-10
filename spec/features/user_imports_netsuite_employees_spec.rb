require "rails_helper"

feature "User imports netsuite employees" do
  before do
    stub_request(:get, "#{ api_host }/api/v1/profiles")
      .with(query: {access_token: ENV['TEST_NAMELY_ACCESS_TOKEN'], limit: 'all'})
      .to_return(status: 200, body: File.read("spec/fixtures/api_responses/empty_profiles.json"))
  end
  let(:api_host) do
    "%{protocol}://%{subdomain}.namely.com" % {
      protocol: Rails.configuration.namely_api_protocol,
      subdomain: ENV['TEST_NAMELY_SUBDOMAIN'],
    }
  end
  scenario "successfully" do
    user = create(:user)
    netsuite_employee = {
      email: "bdickens@ramsey.com",
      first_name: "Brandy",
      internal_id: "912",
      last_name: "Dickens",
      is_inactive: "false",
      gender: "female",
    }

    stub_request(:post, "#{ api_host }/api/v1/profiles")
      .to_return(status: 200, body: File.read("spec/fixtures/api_responses/not_empty_profiles.json"))
    stub_request(:get, "#{ api_host }/api/v1/profiles")
      .to_return(status: 200, body: File.read("spec/fixtures/api_responses/not_empty_profiles.json"))
    stub_request(:get, ENV["NETSUITE_GATEWAY_URL"]).
      to_return(body: [netsuite_employee].to_json)

    visit dashboard_path(as: user)
    click_button t("dashboards.show.import_now")

    expect(page).to have_content t("status.imported_successfully")
  end
end
