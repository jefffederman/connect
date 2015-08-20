require "rails_helper"

feature "User deletes Greenhouse connection" do
  scenario "successfully" do
    user = create(:user)
    create(
      :greenhouse_connection,
      :connected,
      installation: user.installation,
      found_namely_field: true,
    )

    visit dashboard_path(as: user)

    within(".greenhouse-account") do
      expect(page).to have_button t("dashboards.show.disconnect")
    end

    within(".greenhouse-account") do
      click_button t("dashboards.show.disconnect")
    end

    within(".greenhouse-account") do
      expect(page).not_to have_button t("dashboards.show.disconnect")
      expect(page).to have_link t("dashboards.show.connect")
    end
  end
end
