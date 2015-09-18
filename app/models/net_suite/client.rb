module NetSuite
  class Client
    REQUEST_BASE = "/hubs/erp"
    EMPLOYEE_REQUEST = REQUEST_BASE + "/employees"
    SUBSIDIARY_REQUEST = REQUEST_BASE + "/lookups/subsidiary"
    INSTANCES = "/instances"

    delegate :get_json, to: :request
    delegate :submit_json, to: :request

    def self.from_env
      new(
        user_secret: ENV["CLOUD_ELEMENTS_USER_SECRET"],
        organization_secret: ENV["CLOUD_ELEMENTS_ORGANIZATION_SECRET"]
      )
    end

    def initialize(
      user_secret:,
      organization_secret:,
      element_secret: nil
    )
      @user_secret = user_secret
      @organization_secret = organization_secret
      @element_secret = element_secret
    end

    def authorize(element_secret)
      self.class.new(
        user_secret: @user_secret,
        organization_secret: @organization_secret,
        element_secret: element_secret
      )
    end

    def create_instance(authentication)
      submit_json(
        :post,
        INSTANCES,
        Instance.new(authentication).to_h
      )
    end

    def create_employee(params)
      Rails.logger.debug { "Creating employee: #{params.to_json}" }
      submit_json(
        :post,
        EMPLOYEE_REQUEST,
        params
      )
    end

    def update_employee(id, params)
      Rails.logger.debug { "Update employee #{id.inspect}: #{params.to_json}" }
      submit_json(
        :patch,
        "#{EMPLOYEE_REQUEST}/#{id}",
        params
      )
    end

    def subsidiaries
      get_json(SUBSIDIARY_REQUEST)
    end

    def profile_fields
      @profile_fields ||= NetSuite::EmployeeFieldsLoader.new(
        request: request
      ).load_profile_fields
    end

    def request
      @request ||= Request.new(
        element_secret: @element_secret,
        organization_secret: @organization_secret,
        user_secret: @user_secret
      )
    end
  end
end
