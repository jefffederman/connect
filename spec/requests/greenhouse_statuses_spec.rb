require "rails_helper"

describe "Greenhouse new candidate" do
  let(:api_host) do
    "%{protocol}://%{subdomain}.namely.com" % {
      protocol: Rails.configuration.namely_api_protocol,
      subdomain: ENV["TEST_NAMELY_SUBDOMAIN"],
    }
  end
  let(:connection) do
    create(:greenhouse_connection, :with_namely_field, name: "myhook")
  end

  before do
    stub_request(:get, %r{#{ api_host }/api/v1/profiles/fields}).
      to_return(
        status: 200,
        body: File.read("spec/fixtures/api_responses/fields_with_greenhouse.json")
      )
  end

  it 'authorize request coming from greenhouse with valid digest' do
    allow_any_instance_of(Greenhouse::ValidRequesterPolicy).to receive(:valid?) { true }
    post(greenhouse_candidate_imports_url(connection.secret_key),
         { greenhouse_candidate_import: greenhouse_ping },
         { "Signature" => "sha256 kdkjadk92929394ajdskfjadf" })
    expect(response.body).to be_blank
    expect(response.status).to eql 200
  end

  it 'unauthorize request not coming from greenhouse with valid digest' do
    allow_any_instance_of(Greenhouse::ValidRequesterPolicy).to receive(:valid?) { false }
    post(greenhouse_candidate_imports_url(connection.secret_key),
         { greenhouse_candidate_import: greenhouse_ping },
         { "Signature" => "sha256 kdkjadk92929394ajdskfjadf" })
    expect(response.body).to be_blank
    expect(response.status).to eql 401
  end

  it "creates new user in namely" do
    stub_request(:post, "#{api_host}/api/v1/profiles").
      to_return(
        status: 200,
        body: File.read("spec/fixtures/api_responses/not_empty_profiles.json"),
      )

    post greenhouse_candidate_imports_url(connection.secret_key), greenhouse_candidate_import: greenhouse_payload

    expect(response.body).to be_blank
    expect(response.status).to eq 200
    expect(sent_email.subject).to include(
      t(
        "candidate_import_mailer.successful_import.subject",
        candidate_name: candidate_name,
        integration: "Greenhouse"
      ).chomp
    )
  end

  it "fails to create a new user in namely" do
    stub_request(:post, "#{api_host}/api/v1/profiles").
      to_return(
        status: 200,
        body: File.read("spec/fixtures/api_responses/empty_profiles.json"),
      )

    post greenhouse_candidate_imports_url(connection.secret_key), greenhouse_candidate_import: greenhouse_payload

    expect(response.body).to be_blank
    expect(response.status).to eq 200
    expect(sent_email.subject).to include(
      t(
        "candidate_import_mailer.unsuccessful_import.subject",
        candidate_name: candidate_name,
        integration: "Greenhouse"
      ).chomp
    )
  end

  let(:greenhouse_ping) do
    JSON.parse(
      File.read('spec/fixtures/api_requests/greenhouse_payload_ping.json'))
  end

  let(:sent_email) do
    ActionMailer::Base.deliveries.first
  end

  let(:greenhouse_payload) do
    JSON.parse(
      File.read("spec/fixtures/api_requests/greenhouse_payload.json")
    )
  end

  def candidate_name
    "Johnny Smith"
  end
end
