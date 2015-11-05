require "rails_helper"

feature "User edits connection configuration" do
  scenario "successfully" do
    user = create(:user)
    connection = create(
      :net_suite_connection,
      :connected,
      :with_namely_field,
      installation: user.installation,
      subsidiary_id: 123,
      matching_type: "email_matcher",
    )

    visit dashboard_path(as: user)
    click_net_suite_configuration_link

    expect(page).not_to have_selector("#net_suite_connection_subsidiary_id")

    find("#net_suite_connection_matching_type").select("Name")
    click_button t("dashboards.show.connect")

    visit edit_integration_connection_path(connection.integration_id)

    expect(find("#net_suite_connection_matching_type").value).to eq("name_matcher")
  end

  def click_net_suite_configuration_link
    within(".net-suite-account") do
      click_link t("dashboards.show.edit_configuration")
    end
  end

  def subsidiary_id_field
    find("#net_suite_connection_subsidiary_id")
  end
end
