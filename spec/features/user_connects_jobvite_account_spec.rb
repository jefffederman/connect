require "rails_helper"

feature "User connects jobvite account" do
  scenario "successfully" do
    stub_namely_fields("fields_with_jobvite")
    user = create(:user)

    visit dashboard_path(as: user)

    within(".jobvite-account") do
      expect(page).not_to have_link t("dashboards.show.edit")
      click_link t("dashboards.show.connect")
    end

    fill_in field("jobvite_authentication.api_key"), with: "12345"
    fill_in field("jobvite_authentication.secret"), with: "abcde"
    click_button button("jobvite_connection.update")
    click_on t("attribute_mappings.edit.save")

    within(".jobvite-account") do
      expect(page).not_to have_link t("dashboards.show.connect")
    end
  end
end
