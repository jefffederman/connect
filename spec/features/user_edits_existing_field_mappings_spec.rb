require "rails_helper"

feature "User edits existing field mappings" do
  scenario "successfully" do
    personal_email = { text: "Personal email", value: "personal_email" }
    stub_namely_fields("fields_with_jobvite")
    user = create(:user)
    create(
      :jobvite_connection,
      :connected,
      :with_namely_field,
      installation: user.installation
    )

    visit dashboard_path(as: user)
    click_jobvite_mappings_link
    first_mappable_field.select(personal_email[:text])
    click_button t("attribute_mappings.edit.save")
    click_jobvite_mappings_link

    expect(first_mappable_field.value).to eq(personal_email[:value])
  end

  def click_jobvite_mappings_link
    within(".jobvite-account") do
      click_link t("dashboards.show.edit_mappings")
    end
  end

  def first_mappable_field
    find("select", match: :first)
  end
end
