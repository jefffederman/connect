require "rails_helper"

feature "User imports netsuite employees" do
  scenario "successfully" do
    user = create(:user)

    # VCR.use_cassette("netsuite_gateway_import") do
      visit dashboard_path(as: user)
      click_button t("dashboards.show.import_now")

      expect(page).to have_content t("status.success")
    # end
  end
end
