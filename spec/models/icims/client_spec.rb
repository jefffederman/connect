require "rails_helper"

describe Icims::Client do
  describe "#recent_hires" do
    context "when the API request is successful" do
      it "fetches recent hires from the iCIMS API" do
        Timecop.freeze do
          stub_request(:post, "#{icims_customer_api_url}/search/people").
            with(headers: { "Authorization" => hexdigest_matcher }).
            to_return(body: search_results)
          stub_request(:get, "#{icims_customer_api_url}/people/8986").
            with(
              query: { fields: required_fields },
              headers: { "Authorization" => hexdigest_matcher },
            ).
            to_return(
              body: sample_response(
                firstname: "Dade",
                lastname: "Murphy",
                email: "crash.override@example.com",
              ),
              headers: { "Content-Type" => "application/json" },
            )
          connection = double(
            "icims_connection",
            api_url: icims_customer_api_url,
            key: "MY_KEY",
            installation: installation_double,
            username: "USERNAME",
          )
          client = described_class.new(connection)

          recent_hires = client.recent_hires

          first_hire = recent_hires.first
          expect(recent_hires.length).to eq 1
          expect(first_hire).to have_attributes(
            email: "crash.override@example.com",
            firstname: "Dade",
            lastname: "Murphy",
          )
        end
      end
    end

    context "when the JSON response doesn't have candidates" do
      it "returns an empty list of candidates" do
        Timecop.freeze do
          stub_request(:post, "#{icims_customer_api_url}/search/people").
            with(headers: { "Authorization" => hexdigest_matcher }).
            to_return(
              body: '{"searchResults": []}',
              headers: { "Content-Type" => "application/json" },
            )
          connection = double(
            "icims_connection",
            api_url: icims_customer_api_url,
            key: "MY_KEY",
            installation: installation_double,
            username: "USERNAME",
          )

          client = described_class.new(connection)

          expect(client.recent_hires).to be_empty
        end
      end
    end

    context "when the API request fails" do
      it "raises an exception" do
        stub_request(:post, "#{icims_customer_api_url}/search/people").
          to_return(status: 401)

        connection = double(
          "icims_connection",
          api_url: icims_customer_api_url,
          key: "MY_KEY",
          installation: installation_double,
          username: "USERNAME",
        )

        client = described_class.new(connection)

        expect { client.recent_hires }.
          to raise_exception(described_class::Error)
      end
    end
  end

  def required_fields
    Icims::CandidateFind::REQUIRED_FIELDS.join(",")
  end

  def search_results
    {"searchResults" => [{ "id" => 8986 }]}.to_json
  end

  def sample_response(values = {})
    {
      startdate: "2013-05-03",
      email: "jtiberiusd@example.com",
      lastname: "Doe",
      firstname: "Jane",
    }.merge(values).to_json
  end

  def installation_double
    build_stubbed(:installation)
  end
end
