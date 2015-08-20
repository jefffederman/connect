require "rails_helper"

feature "User deletes Jobvite connection" do
  scenario "successfully" do
    user = create(:user)
    create(
      :jobvite_connection,
      :connected,
      installation: user.installation,
      found_namely_field: true,
    )

    visit dashboard_path(as: user)

    within(".jobvite-account") do
      expect(page).to have_button t("dashboards.show.disconnect")
    end

    within(".jobvite-account") do
      click_button t("dashboards.show.disconnect")
    end

    within(".jobvite-account") do
      expect(page).not_to have_button t("dashboards.show.disconnect")
      expect(page).to have_link t("dashboards.show.connect")
    end
  end
end
