require "rails_helper"

feature "user tries to import icims person again" do
  let(:api_host) do
    "%{protocol}://%{subdomain}.namely.com" % {
      protocol: Rails.configuration.namely_api_protocol,
      subdomain: ENV["TEST_NAMELY_SUBDOMAIN"],
    }
  end

  scenario "creates new user in namely" do
    stub_person_results
    user = user_with_icims_connection

    stub_request(:post, "#{api_host}/api/v1/profiles").
      to_return(
        status: 200,
        body: File.read("spec/fixtures/api_responses/not_empty_profiles.json"),
      )

    visit icims_candidate_retry_import_path(9166, as: user)

    expect(page).
      to have_content(t("icims_candidate_retry_imports.show.successful", name: candidate_name))
  end

  scenario "fails to create a new user in namely" do
    stub_incomplete_person_results
    user = user_with_icims_connection

    visit icims_candidate_retry_import_path(9166, as: user)

    expect(page).
      to have_content(t("icims_candidate_retry_imports.show.unsuccessful", name: candidate_name))
    expect(page).
      to have_content(t("icims_candidate_retry_imports.show.retry"))
  end

  def stub_person_results
    stub_request(:get, "https://api.icims.com/customers/2187/people/9166").
      with(query: { fields: required_fields }).
      to_return(
        body: File.read("spec/fixtures/api_responses/first_icims_candidate.json")
      )
  end

  def user_with_icims_connection
    create(:user).tap do |user|
      create(
        :icims_connection,
        :with_namely_field,
        customer_id: 2187,
        installation: user.installation,
        key: "KEY",
        username: "USERNAME",
      )
    end
  end

  def required_fields
    Icims::CandidateFind::REQUIRED_FIELDS.join(",")
  end

  def sent_email
    @sent_email ||= ActionMailer::Base.deliveries.first
  end

  def stub_incomplete_person_results
    stub_request(:get, "https://api.icims.com/customers/2187/people/9166").
      with(query: { fields: required_fields }).
      to_return(
        body: File.read("spec/fixtures/api_responses/incomplete_icims_candidate.json")
      )
  end

  def candidate_name
    "Jane Doe"
  end
end
