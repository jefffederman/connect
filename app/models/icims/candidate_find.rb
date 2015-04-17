module Icims
  class CandidateFind
    REQUIRED_FIELDS = [
      "addresses",
      "email",
      "firstname",
      "gender",
      "lastname",
      "phones",
      "salary",
      "startdate",
    ]

    def initialize(connection:, authorized_request: AuthorizedRequest)
      @connection = connection
      @authorized_request = authorized_request
    end

    def find(id)
      JSON.parse(get_candidate(id)).
        merge("id" => id)
    end

    private

    attr_reader :connection, :authorized_request

    def get_candidate(person_id)
      authorized_request.new(
        connection: connection,
        request: get_candidate_request(person_id)
      ).execute
    end

    def get_candidate_request(person_id)
      RestClient::Request.new(
        method: :get,
        url: person_url(person_id),
        headers: {
          params: { fields: required_person_fields },
        },
      )
    end

    def person_url(person_id)
      "#{connection.api_url}/people/#{person_id}"
    end

    def required_person_fields
      REQUIRED_FIELDS.join(",")
    end
  end
end
