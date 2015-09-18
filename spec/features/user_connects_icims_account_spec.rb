require "rails_helper"

feature "User connects iCIMS account" do
  scenario "successfully" do
    stub_namely_fields("fields_with_icims")
    user = create(:user)
    allow(SecureRandom).to receive(:hex).and_return("api_key")

    visit dashboard_path(as: user)

    within(".icims-account") do
      expect(page).to have_no_link t("dashboards.show.edit")
      click_link t("dashboards.show.connect")
    end

    fill_in field("icims_authentication.username"), with: "username"
    fill_in field("icims_authentication.key"), with: "key"
    fill_in field("icims_authentication.customer_id"), with: 1
    click_button button("icims_connection.update")

    within(".icims-account") do
      expect(page).to have_no_link t("dashboards.show.connect")
      expect(find_field(t("dashboards.show.webhook_label")).value).
        to eq icims_candidate_imports_url("api_key")
    end
  end
end
