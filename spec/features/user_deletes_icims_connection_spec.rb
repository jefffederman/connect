require "rails_helper"

feature "User deletes iCIMS connection" do
  scenario "successfully" do
    user = create(:user)
    create(
      :icims_connection,
      :connected,
      installation: user.installation,
      found_namely_field: true,
    )

    visit dashboard_path(as: user)

    within(".icims-account") do
      expect(page).to have_button t("dashboards.show.disconnect")
    end

    within(".icims-account") do
      click_button t("dashboards.show.disconnect")
    end

    within(".icims-account") do
      expect(page).not_to have_button t("dashboards.show.disconnect")
      expect(page).to have_link t("dashboards.show.connect")
    end
  end
end
