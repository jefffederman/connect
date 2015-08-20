require "rails_helper"

describe Jobvite::Client do
  describe "#recent_hires" do
    context "when the API request is successful" do
      it "fetches recent hires from the Jobvite API" do
        stub_request(:get, "https://api.jobvite.com/api/v2/candidate").
          with(query: hash_including(
            "api" => "MY_API_KEY",
            "sc" => "MY_SECRET",
            "wflowstate" => "Hired",
          )).
          to_return(
            body: sample_response(
              first_name: "Dade",
              last_name: "Murphy",
              email: "crash.override@example.com",
              start_date: DateTime.new(2014, 1, 1),
              gender: "male",
            ),
            headers: { "Content-Type" => "application/json" },
          )
        connection = double(
          "jobvite_connection",
          api_key: "MY_API_KEY",
          hired_workflow_state: "Hired",
          secret: "MY_SECRET",
          installation: installation_double,
        )

        client = described_class.new(connection)

        recent_hires = client.recent_hires

        first_hire = recent_hires.first
        expect(recent_hires.length).to eq 1
        expect(first_hire.first_name).to eq "Dade"
        expect(first_hire.last_name).to eq "Murphy"
        expect(first_hire.email).to eq "crash.override@example.com"
      end

      context "when the json response doesn't have candidates" do 
        it 'returns an empty list of candidates' do 
          stub_request(:get, "https://api.jobvite.com/api/v2/candidate").
            with(query: hash_including(
              "api" => "MY_API_KEY",
              "sc" => "MY_SECRET",
              "wflowstate" => "Hired",
          )).
          to_return(
            body: '{"persons": []}',
            headers: { "Content-Type" => "application/json" },
          )

          connection = double(
            "jobvite_connection",
            api_key: "MY_API_KEY",
            hired_workflow_state: "Hired",
            secret: "MY_SECRET",
            installation: installation_double,
          )

          client = described_class.new(connection)

          expect(client.recent_hires.size).to eql 0
        end
      end
    end

    context "when the number of candidates spans more than one page" do
      it "fetches and returns recent hires from all pages" do
        stub_request(:get, "https://api.jobvite.com/api/v2/candidate").
          with(query: hash_including(
            "api" => "MY_API_KEY",
            "sc" => "MY_SECRET",
            "start" => "1",
          )).
          to_return(
            body: sample_response(
              total: 51,
              first_name: "Dade",
              last_name: "Murphy",
              email: "crash.override@example.com",
            ),
            headers: { "Content-Type" => "application/json" },
          )
        stub_request(:get, "https://api.jobvite.com/api/v2/candidate").
          with(query: hash_including(
            "api" => "MY_API_KEY",
            "sc" => "MY_SECRET",
            "start" => "51",
          )).
          to_return(
            body: sample_response(
              total: 51,
              first_name: "Kate",
              last_name: "Libby",
              email: "acid.burn@example.com",
            ),
            headers: { "Content-Type" => "application/json" },
          )

        connection = double(
          "jobvite_connection",
          api_key: "MY_API_KEY",
          hired_workflow_state: "Offer Accepted",
          secret: "MY_SECRET",
          installation: installation_double,
        )

        client = described_class.new(connection)

        recent_hires = client.recent_hires

        expect(recent_hires.map(&:first_name)).to eq ["Dade", "Kate"]
      end
    end

    context "when the API request fails" do
      it "raises an exception" do
        stub_request(:get, "https://api.jobvite.com/api/v2/candidate").
          with(query: hash_including("api" => "MY_API_KEY", "sc" => "MY_SECRET")).
          to_return(
            body: '{"errors":{"code":400,"messages":["an error message"]}}',
            headers: { "Content-Type" => "application/json" },
          )
        connection = double(
          "jobvite_connection",
          api_key: "MY_API_KEY",
          hired_workflow_state: "Offer Accepted",
          secret: "MY_SECRET",
          installation: installation_double,
        )

        client = described_class.new(connection)

        expect { client.recent_hires }.
          to raise_exception(described_class::Error)
      end
    end

    context "on authentication failure" do
      it "returns invalid authentication message" do
        stub_request(:get, "https://api.jobvite.com/api/v2/candidate").
          with(
            query: hash_including("api" => "MY_API_KEY", "sc" => "MY_SECRET")
          ).
          to_return(
            body: <<-JSON
              {
                "status":"INVALID_KEY_SECRET",
                "responseMessage":"An error message"
              }
            JSON
          )

        installation = installation_double
        connection = double(
          "jobvite_connection",
          api_key: "MY_API_KEY",
          hired_workflow_state: "Offer Accepted",
          secret: "MY_SECRET",
          installation: installation,
        )

        client = Jobvite::Client.new(connection)

        exception = Unauthorized.new("An error message")
        allow(installation).to receive(:send_connection_notification)

        expect { client.recent_hires }.to raise_error(Unauthorized)
        expect(installation).to have_received(:send_connection_notification).
          with(integration_id: "jobvite", message: exception.message)
      end
    end
  end

  def installation_double
    build_stubbed(:installation)
  end

  def sample_response(values = {})
    <<-JSON
{
  "candidates": [
    {
      "address": "",
      "address2": "",
      "application": {
        "comments": null,
        "customField": [],
        "disposition": null,
        "eId": "pN0gfhw4",
        "gender": "#{values.fetch(:gender, "Undefined")}",
        "hireDate": 1415088000000,
        "job": {
          "company": null,
          "customField": null,
          "department": null,
          "eId": null,
          "hiringManagers": null,
          "location": null,
          "recruiters": null,
          "requisitionId": null,
          "subsidiaryId": null,
          "title": null
        },
        "lastUpdatedDate": 1415088000000,
        "race": "Decline to Self Identify",
        "source": "Eugene Belford",
        "sourceType": "Recruiter",
        "startDate": #{values.fetch(:start_date, DateTime.now).to_i * 1000},
        "status": null,
        "veteranStatus": "Undefined"
      },
      "city": "",
      "companyName": "",
      "country": "",
      "eId": "edO1Ggwt",
      "email": "#{values.fetch(:email)}",
      "firstName": "#{values.fetch(:first_name)}",
      "homePhone": "",
      "lastName": "#{values.fetch(:last_name)}",
      "location": ",  ",
      "postalCode": null,
      "state": "",
      "title": "",
      "workPhone": "",
      "workStatus": "None"
    }
  ],
  "total": #{values.fetch(:total, 1).to_i}
}
    JSON
  end
end
