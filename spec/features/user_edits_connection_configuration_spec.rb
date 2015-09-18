require "rails_helper"

feature "User edits connection configuration" do
  scenario "successfully" do
    original_subsidiary = { internalId: "1", name: "Original" }
    new_subsidiary = { internalId: "2", name: "New" }
    user = create(:user)
    connection = create(
      :net_suite_connection,
      :connected,
      :with_namely_field,
      installation: user.installation,
      subsidiary_id: original_subsidiary[:internalId]
    )
    stub_mapping_requests
    stub_net_suite_subsidiaries(
      status: 200,
      body: [original_subsidiary, new_subsidiary]
    )

    visit dashboard_path(as: user)
    click_net_suite_configuration_link
    subsidiary_id_field.select(new_subsidiary[:name])
    click_button t("dashboards.show.connect")
    visit edit_integration_connection_path(connection.integration_id)

    expect(subsidiary_id_field.value).
      to eq new_subsidiary[:internalId]
  end

  def click_net_suite_configuration_link
    within(".net-suite-account") do
      click_link t("dashboards.show.edit_configuration")
    end
  end

  def subsidiary_id_field
    find("#net_suite_connection_subsidiary_id")
  end

  def stub_mapping_requests
    stub_net_suite_fields
    stub_namely_fields("fields_with_net_suite")
  end
end
