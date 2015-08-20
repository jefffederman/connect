require "rails_helper"

feature "User visits their dashboard" do
  let(:api_host) do
    "%{protocol}://%{subdomain}.namely.com" % {
      protocol: Rails.configuration.namely_api_protocol,
      subdomain: ENV['TEST_NAMELY_SUBDOMAIN'],
    }
  end

  scenario "user can sign out after" do 
    stub_namely_fields("fields_without_jobvite")
    user = create(:user)
    create(
      :jobvite_connection,
      :connected,
      installation: user.installation,
      found_namely_field: false,
    )

    visit dashboard_path(as: user)

    click_link t("dashboards.show.sign_out")
    expect(page.current_path).to eql root_path
  end

  context "with a Jobvite connection, but no Jobvite field on Namely" do
    scenario "user is told that the Jobvite field is missing and isn't shown an import button" do
      stub_namely_fields("fields_without_jobvite")
      user = create(:user)
      create(
        :jobvite_connection,
        :connected,
        installation: user.installation,
        found_namely_field: false,
      )


      visit dashboard_path(as: user)

      within(".jobvite-account") do
        expect(page).to have_content t(
          "dashboards.show.missing_namely_field",
          name: "jobvite_id",
        )
        expect(page).not_to have_import_button
      end
    end
  end

  context "with a Jobvite connection, and a Jobvite field on Namely" do
    scenario "user can click an import button" do
      stub_namely_fields("fields_with_jobvite")
      user = create(:user)
      create(
        :jobvite_connection,
        :connected,
        installation: user.installation,
        found_namely_field: true,
      )

      visit dashboard_path(as: user)

      within(".jobvite-account") do
        expect(page).not_to have_content t(
          "dashboards.show.missing_namely_field",
          name: "jobvite_id",
        )
        expect(page).to have_import_button
      end
    end
  end

  context "with a iCIMS connection, but no iCIMS field on Namely" do
    scenario "user is told that the iCIMS field is missing and isn't shown an import button" do
      stub_namely_fields("fields_without_icims")
      user = create(:user)
      create(
        :icims_connection,
        :connected,
        installation: user.installation,
        found_namely_field: false,
      )

      visit dashboard_path(as: user)

      within(".icims-account") do
        expect(page).to have_content t(
          "dashboards.show.missing_namely_field",
          name: "icims_id",
        )
        expect(page).to have_no_button t("dashboards.show.import_now")
      end
    end
  end

  context "with a iCIMS connection, and a iCIMS field on Namely" do
    scenario "user can click an import button" do
      allow(SecureRandom).to receive(:hex).and_return("api_key")
      stub_namely_fields("fields_with_icims")
      user = create(:user)
      connection = create(
        :icims_connection,
        :connected,
        installation: user.installation,
        found_namely_field: true,
      )

      visit dashboard_path(as: user)

      within(".icims-account") do
        expect(page).not_to have_content t(
          "dashboards.show.missing_namely_field",
          name: "icims_id",
        )
        expect(page).
          to have_content(icims_candidate_imports_url(connection.api_key))
      end
    end
  end

  context "with a Greenhouse connection, but no Greenhouse field on Namely" do
    scenario "user is told that the Greenhouse field is missing" do
      stub_namely_fields("fields_without_greenhouse")
      user = create(:user)
      create(
        :greenhouse_connection,
        :connected,
        installation: user.installation,
        found_namely_field: false,
      )

      visit dashboard_path(as: user)

      within(".greenhouse-account") do
        expect(page).to have_content t(
          "dashboards.show.missing_namely_field",
          name: "greenhouse_id",
        )
      end
    end
  end

  context "with a Greenhouse connection and field exists on Namely" do
    scenario "user can see the response url" do
      allow(SecureRandom).to receive(:hex).and_return("secret_key")
      stub_namely_fields("fields_with_greenhouse")
      user = create(:user)
      connection = create(
        :greenhouse_connection,
        :connected,
        installation: user.installation,
        found_namely_field: true,
      )

      visit dashboard_path(as: user)

      within(".greenhouse-account") do
        expect(page).not_to have_content t(
          "dashboards.show.missing_namely_field",
          name: "greenhouse_id",
        )
        expect(page).
          to have_content(greenhouse_candidate_imports_url(connection.secret_key))
      end
    end
  end

  context "with a NetSuite connection, but no NetSuite field on Namely" do
    scenario "user is told that the NetSuite field is missing" do
      stub_namely_fields("fields_without_net_suite")
      user = create(:user)
      create(
        :net_suite_connection,
        :connected,
        installation: user.installation,
        found_namely_field: false,
      )

      visit dashboard_path(as: user)

      within(".net-suite-account") do
        expect(page).to have_content t(
          "dashboards.show.missing_namely_field",
          name: "netsuite_id",
        )
        expect(page).not_to have_export_button
      end
    end
  end

  context "with a NetSuite connection, and a NetSuite field on Namely" do
    scenario "user can click an import button" do
      stub_namely_fields("fields_with_net_suite")
      user = create(:user)
      create(
        :net_suite_connection,
        :connected,
        installation: user.installation,
        found_namely_field: true,
      )

      visit dashboard_path(as: user)

      within(".net-suite-account") do
        expect(page).not_to have_content t(
          "dashboards.show.missing_namely_field",
          name: "netsuite_id",
        )
        expect(page).to have_export_button
      end
    end
  end

  def have_import_button
    have_button t("dashboards.show.import_now")
  end

  def have_export_button
    have_button t("dashboards.show.export_now")
  end
end
