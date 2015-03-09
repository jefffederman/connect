require "rails_helper"

feature "User imports netsuite employees" do
  scenario "successfully" do
    user = create(:user)
    netsuite_employee = double(
      "NetsuiteEmployee",
      email: "bdickens@ramsey.com",
      first_name: "Brandy",
      internal_id: "912",
      last_name: "Dickens",
      is_inactive: "false",
      gender: "female",
    )
    allow_any_instance_of(Netsuite::Import).to receive(:netsuite_employees).and_return([netsuite_employee])

    visit dashboard_path(as: user)
    click_button t("dashboards.show.import_now")

    expect(page).to have_content t("status.success")
  end
end
