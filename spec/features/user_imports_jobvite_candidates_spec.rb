require "rails_helper"

feature "User imports jobvite candidates" do
  before do
    stub_request(:get, /.*api.jobvite.com\/api\/v2\/candidate/)
      .to_return(status: 200, body: File.read("spec/fixtures/api_responses/jobvite_candidates.json"))
  end
  before do
    stub_request(:get, /.*api\/v1\/profiles\/fields/)
      .to_return(status: 200, body: File.read("spec/fixtures/api_responses/fields_with_jobvite.json"))
  end
  before do
    stub_request(:get, "#{ api_host }/api/v1/profiles")
      .with(query: {access_token: ENV['TEST_NAMELY_ACCESS_TOKEN'], limit: 'all'})
      .to_return(status: 200, body: File.read("spec/fixtures/api_responses/empty_profiles.json"))
  end
  before do
    stub_request(:post, "#{ api_host }/api/v1/profiles")
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
    create(
      :jobvite_connection,
      user: user,
      api_key: ENV.fetch("TEST_JOBVITE_KEY"),
      secret: ENV.fetch("TEST_JOBVITE_SECRET"),
    )

    visit dashboard_path(as: user)
    click_button t("dashboards.show.import_now")
    page.save_page("a.html")

    expect(page).to have_content t("jobvite_imports.create.title_successful")
  end
end
