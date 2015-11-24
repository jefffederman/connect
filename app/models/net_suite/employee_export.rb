module NetSuite
  class EmployeeExport
    def initialize(profile:, attributes:, netsuite_client:, netsuite_id: nil)
      @attributes = attributes
      @profile = profile
      @netsuite_client = netsuite_client
      @netsuite_id = netsuite_id
    end

    def update
      Rails.logger.info "Updating NetSuite employee: #{netsuite_id}"
      request(updated: true) do
        response = netsuite_client.update_employee(netsuite_id, attributes)
        profile.update(netsuite_id: netsuite_id)
        response
      end
    end

    def create
      Rails.logger.info "Creating NetSuite employee from Namely Profile: #{profile.id}"
      request(updated: false) do
        response = netsuite_client.create_employee(attributes)

        Rails.logger.info "Updating Namely profile #{profile.id} with NetSuite ID: #{response["internalId"]}"

        profile.update(netsuite_id: response["internalId"])
        response
      end
    end

    private

    attr_reader :attributes, :profile, :netsuite_client, :netsuite_id

    def request(updated:)
      yield
      Result.new(
        success: true,
        error: nil,
        updated: updated,
        profile: profile
      )
    rescue NetSuite::ApiError => exception
      Result.new(
        success: false,
        error: exception.to_s,
        updated: updated,
        profile: profile
      )
    end
  end

  class Result
    def initialize(success:, error:, updated:, profile:)
      @success = success
      @error = error
      @updated = updated
      @profile = profile
    end

    attr_reader :error
    delegate :email, :name, to: :profile

    def profile_id
      @profile.id
    end

    def success?
      @success == true
    end

    def updated?
      @updated
    end

    protected

    attr_reader :profile
  end
end
