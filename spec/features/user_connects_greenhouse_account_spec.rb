require "rails_helper"

feature "User connects Greenhouse account" do
  scenario "successfully" do
    stub_namely_fields("fields_with_greenhouse")
    user = create(:user)
    allow(SecureRandom).to receive(:hex).and_return("greenhouse_key")

    visit dashboard_path(as: user)

    within(".greenhouse-account") do
      expect(page).to have_no_link t("dashboards.show.edit")
      click_link t("dashboards.show.connect")
    end

    fill_in field("greenhouse_authentication.name"), with: "name"
    click_button button("greenhouse_connection.update")

    click_on t("attribute_mappings.edit.save")

    within(".greenhouse-account") do
      expect(page).to have_no_link t("dashboards.show.connect")
      expect(find_field(t("dashboards.show.webhook_label")).value).
        to eq greenhouse_candidate_imports_url("greenhouse_key")
    end
  end
end
