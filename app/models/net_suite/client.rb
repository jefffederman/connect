module NetSuite
  class Client
    REQUEST_BASE = "/hubs/erp"
    EMPLOYEE_REQUEST = REQUEST_BASE + "/employees"
    SUBSIDIARY_REQUEST = REQUEST_BASE + "/lookups/subsidiary"
    INSTANCES = "/instances"
    PAGE_SIZE = 5000

    delegate :get_json, to: :request
    delegate :submit_json, to: :request
    attr_reader :partner_id, :app_id

    def self.from_env
      new(
        user_secret: ENV["CLOUD_ELEMENTS_USER_SECRET"],
        organization_secret: ENV["CLOUD_ELEMENTS_ORGANIZATION_SECRET"],
        partner_id: ENV["NETSUITE_PARTNER_ID"],
        app_id: ENV["NETSUITE_APP_ID"]
      )
    end

    def initialize(
      user_secret:,
      organization_secret:,
      partner_id:,
      app_id:,
      element_secret: nil
    )
      @user_secret = user_secret
      @organization_secret = organization_secret
      @element_secret = element_secret
      @partner_id = partner_id
      @app_id = app_id
    end

    def authorize(element_secret)
      self.class.new(
        user_secret: @user_secret,
        organization_secret: @organization_secret,
        partner_id: @partner_id,
        app_id: @app_id,
        element_secret: element_secret
      )
    end

    def create_instance(authentication)
      submit_json(
        :post,
        INSTANCES,
        Instance.new(authentication: authentication).to_h
      )
    end

    def create_employee(params)
      Rails.logger.debug("Creating employee: #{params.to_json}")
      submit_json(
        :post,
        EMPLOYEE_REQUEST,
        params
      )
    end

    def update_employee(id, params)
      Rails.logger.debug("Update employee #{id.inspect}: #{params.to_json}")
      submit_json(
        :patch,
        "#{EMPLOYEE_REQUEST}/#{id}",
        params
      )
    end

    def employees
      Rails.logger.debug("Get employees")

      get_json(EMPLOYEE_REQUEST, paginated: true)
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
