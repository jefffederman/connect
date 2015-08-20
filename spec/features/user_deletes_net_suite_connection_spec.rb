require "rails_helper"

feature "user deletes NetSuite connection" do
  scenario "successfully" do
    user = create(:user)
    create(
      :net_suite_connection,
      :connected,
      :with_namely_field,
      installation: user.installation
    )

    visit dashboard_path(as: user)

    within(".net-suite-account") do
      click_button t("dashboards.show.disconnect")
    end

    within(".net-suite-account") do
      expect(page).to have_link t("dashboards.show.connect")
      expect(page).not_to have_button t("dashboards.show.disconnect")
    end
  end
end
