require "rails_helper"

feature "Visitor authenticates with Namely" do
  include_context 'subdomain'
  class FakeNamely
    def call(env)
      request = Rack::Request.new(env)
      if request.path == "/api/v1/oauth2/authorize"
        redirect_uri = "%{base_uri}?code=%{code}&state=%{state}" % {
          base_uri: request["redirect_uri"],
          code: ENV.fetch("TEST_NAMELY_AUTH_CODE", 'test'),
          state: request["state"],
        }
        return Rack::Response.new([], 302, { "Location" => redirect_uri }).to_a
      end
    end
  end

  before do
    stub_request(:post, "#{ api_host }/api/v1/oauth2/token")
      .with(query: {redirect_uri: "#{ ENV['HOST'] }/session/oauth_callback"})
      .to_return(status: 200, body: JSON.dump(tokens))
  end

  before do
    stub_request(:get, "#{ api_host }/api/v1/profiles/me")
      .with(query: {access_token: ENV['TEST_NAMELY_ACCESS_TOKEN'] })
      .to_return(status: 200, body: JSON.dump(profile))
  end

  let(:api_host) do
    "%{protocol}://%{subdomain}.namely.com" % {
      protocol: Rails.configuration.namely_api_protocol,
      subdomain: ENV['TEST_NAMELY_SUBDOMAIN'],
    }
  end

  let(:tokens) do
    {
      access_token: ENV['TEST_NAMELY_ACCESS_TOKEN'],
      refresh_token: ENV['TEST_NAMELY_REFRESH_TOKEN'],
      token_type: "bearer",
      expires_in: 899
    }
  end

  let(:profile) do
    {
      profiles: [
        {
          id: "12672434-f539-4e55-b499-e2b7885e7e6a",
          email: "test@example.com",
          first_name: "Test",
          last_name: "Test",
          user_status: "active",
          links:{}
        }
      ],
      meta:{
        count:1,
        status:200
      },
      links:{},linked:{}
    }
  end


  scenario "successfully", :js do
    Capybara::Discoball.spin(FakeNamely) do |server|
      Rails.configuration.namely_authentication_domain = "#{server.host}:#{server.port}"
      Rails.configuration.namely_authentication_protocol = "http"
    end

    visit root_path
    fill_in "namely_authentication[subdomain]", with: ENV['TEST_NAMELY_SUBDOMAIN']
    click_button button("namely_authentication.submit")

    expect(page.current_path).to eq dashboard_path
    expect(page).to have_content "Test Test"
  end

  scenario "unsuccessfully" do
    Capybara::Discoball.spin(FakeNamely) do |server|
      Rails.configuration.namely_authentication_domain = "#{server.host}:#{server.port}"
      Rails.configuration.namely_authentication_protocol = "http"
    end

    visit root_path
    fill_in "namely_authentication[subdomain]", with: ""
    click_button button("namely_authentication.submit")

    expect(page.current_path).to eq root_path
  end

  after(:all) do
    Rails.configuration.namely_authentication_domain = ENV.fetch("NAMELY_DOMAIN", "%{subdomain}.namely.com")
    Rails.configuration.namely_authentication_protocol = ENV.fetch("NAMELY_PROTOCOL", "https")
  end
end
