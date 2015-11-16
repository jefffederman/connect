require "rails_helper"

feature "User retries failed profile sync" do
  scenario "sees result in activity feed" do
    user = create(:user)
    connection = create_connection_for(user)
    create_failed_profile_event_for(connection)
    stub_profile_update
    stub_netsuite_employees
    stub_namely_data("/profiles", "profiles_with_net_suite_fields")
    stub_namely_fields("fields_with_net_suite")
    stub_retry_of_failed_profile_event

    visit_activity_feed(connection, user)
    click_on t("profile_event.retry")
    visit_activity_feed(connection, user)

    save_page

    expect(page).to have_text("Successfully synced one profile")
  end

  def create_connection_for(user)
    mapping = create(:field_mapping)
    create(
      :net_suite_connection,
      :ready,
      attribute_mapper: mapping.attribute_mapper,
      installation: user.installation
    )
  end

  def create_failed_profile_event_for(connection)
    sync_summary = create(:sync_summary, connection: connection)
    create(
      :profile_event,
      sync_summary: sync_summary,
      profile_name: "Tina Tech",
      profile_id: "3f51b510-1922-11e5-b939-0800200c9a66",
      error: "Phone number is invalid"
    )
  end

  def stub_retry_of_failed_profile_event
    stub_request(
      :patch,
      "https://api.cloud-elements.com/elements/api-v2/hubs/erp/employees/1234"
    ).with(body: hash_including(firstName: "Tina")).to_return(status: 200)
  end

  def stub_netsuite_employees
    stub_request(
      :get,
      "https://api.cloud-elements.com/elements/api-v2/hubs/erp/employees"
    ).to_return(
      body: [{internalId: "1234", firstName: "TT"}].to_json
    )
  end

  def stub_profile_update
    stub_request(:put, %r{.*api/v1/profiles/.*}).to_return(
      status: 200,
      body: [{id: "3f51b510-1922-11e5-b939-0800200c9a66", first_name: "Tina Tech"}].to_json
    )
  end

  def visit_activity_feed(connection, user)
    visit integration_activity_feed_path(
      integration_id: connection.integration_id,
      as: user
    )
  end
end
