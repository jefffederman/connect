require "rails_helper"

describe NetSuite::Client do
  include Features
  describe ".from_env" do
    it "finds authorization from the environment" do
      env = {
        "CLOUD_ELEMENTS_USER_SECRET" => "user-secret",
        "CLOUD_ELEMENTS_ORGANIZATION_SECRET" => "org-secret",
        "NETSUITE_PARTNER_ID" => "partnerid",
        "NETSUITE_APP_ID" => "appid"
      }

      ClimateControl.modify env do
        stub_request(:post, /.*/)
        client = NetSuite::Client.from_env
        allow(NetSuite::Instance).to receive(:new).and_return({})

        client.create_instance(double("Authentication"))

        expect(WebMock).to have_requested(:post, /.*/).with(
          headers: {
            "Authorization" => "User user-secret, Organization org-secret"
          }
        )
      end
    end
  end

  describe "#authorize" do
    it "sets element authorization" do
      allow(NetSuite::Instance).to receive(:new).and_return({})
      stub_request(:post, /.*/)
      client = NetSuite::Client.new(
        user_secret: "user-secret",
        organization_secret: "org-secret",
        partner_id: "partnerid",
        app_id: "appid",
      )

      client.
        authorize("element-secret").
        create_instance(double("Authentication"))

      expect(WebMock).to have_requested(:post, /.*/).with(
        headers: {
          "Authorization" => "User user-secret, " \
            "Organization org-secret, " \
            "Element element-secret"
        }
      )
    end
  end

  describe "#create_instance" do
    context "on HTTP success" do
      it "returns successful data" do
        authentication = double(NetSuite::Authentication)
        instance_request = { configuration: "foo", elements: "bar" }
        instance_response = { "id" => "123", "token" => "abcxyz" }
        allow(NetSuite::Instance).to receive(:new).
          with(authentication: authentication).
          and_return(instance_request)

        stub_request(
          :post,
          "https://api.cloud-elements.com/elements/api-v2/instances"
        ).
          with(
            body: instance_request.to_json,
            headers: {
              "Authorization" => "User user-secret, Organization org-secret",
              "Content-Type" => "application/json"
            }
          ).
          to_return(status: 200, body: instance_response.to_json)

        client = NetSuite::Client.new(
          user_secret: "user-secret",
          organization_secret: "org-secret",
          partner_id: "partnerid",
          app_id: "appid",
        )

        result = client.create_instance(authentication)

        expect(result["id"]).to eq instance_response["id"]
        expect(result["token"]).to eq instance_response["token"]
      end
    end

    context "on HTTP failure" do
      it "raises an exception" do
        allow(NetSuite::Instance).to receive(:new).and_return({})
        error = "a failure"
        stub_request(
          :post,
          "https://api.cloud-elements.com/elements/api-v2/instances"
        ).
          to_return(status: 400, body: { message: error }.to_json)

        client = NetSuite::Client.new(
          user_secret: "x",
          organization_secret: "x",
          partner_id: "partnerid",
          app_id: "appid",
        )

        expect { client.create_instance(double("Authentication")) }.
          to raise_error(NetSuite::ApiError)
      end
    end

    context "on authentication failure" do
      it "raises an Unauthorized exception" do
        allow(NetSuite::Instance).to receive(:new).and_return({})
        error = "Invalid Organization or User secret, or invalid Element" \
                " token provided."

        stub_request(
          :post,
          "https://api.cloud-elements.com/elements/api-v2/instances"
        ).
          to_return(status: 401, body: { message: error }.to_json)

        client = NetSuite::Client.new(
          user_secret: "x",
          organization_secret: "x",
          partner_id: "partnerid",
          app_id: "appid",
        )

        expect { client.create_instance(double("Authentication")) }.
          to raise_error(Unauthorized)
      end
    end
  end

  describe "#create_employee" do
    context "on HTTP success" do
      it "returns successful data" do
        employee = { internalId: "1949" }
        stub_request(
          :post,
          "https://api.cloud-elements.com/elements/api-v2/hubs/erp/employees"
        ).
          with(
            body: {
              firstName: "Sally",
              lastName: "Sitwell",
              email: "sally@example.com",
              gender: "_female",
              phone: "123-123-1234",
              subsidiary: { internalId: 1 },
              title: "CEO"
            }.to_json,
            headers: {
              "Authorization" => "User user-secret, " \
                "Organization org-secret, " \
                "Element element-secret",
              "Content-Type" => "application/json"
            }
          ).
          to_return(status: 200, body: employee.to_json)

        client = NetSuite::Client.new(
          user_secret: "user-secret",
          organization_secret: "org-secret",
          partner_id: "partnerid",
          app_id: "appid",
          element_secret: "element-secret"
        )

        result = client.create_employee(
          firstName: "Sally",
          lastName: "Sitwell",
          email: "sally@example.com",
          gender: "_female",
          phone: "123-123-1234",
          subsidiary: { internalId: 1 },
          title: "CEO"
        )

        expect(result["internalId"]).to eq("1949")
      end
    end
  end

  describe "#update_employee" do
    context "on HTTP success" do
      it "returns successful data" do
        employee = { internalId: "1949" }
        stub_request(
          :patch,
          "https://api.cloud-elements.com/elements/api-v2" \
          "/hubs/erp/employees/1949"
        ).
          with(
            body: {
              firstName: "Sally",
              lastName: "Sitwell",
              email: "sally@example.com",
              gender: "_female",
              phone: "123-123-1234",
              subsidiary: { internalId: 1 },
              title: "CEO"
            }.to_json,
            headers: {
              "Authorization" => "User user-secret, " \
                "Organization org-secret, " \
                "Element element-secret",
              "Content-Type" => "application/json"
            }
          ).
          to_return(status: 200, body: employee.to_json)

        client = NetSuite::Client.new(
          user_secret: "user-secret",
          organization_secret: "org-secret",
          partner_id: "partnerid",
          app_id: "appid",
          element_secret: "element-secret"
        )

        result = client.update_employee(
          employee[:internalId],
          firstName: "Sally",
          lastName: "Sitwell",
          email: "sally@example.com",
          gender: "_female",
          phone: "123-123-1234",
          subsidiary: { internalId: 1 },
          title: "CEO",
        )

        expect(result["internalId"]).to eq("1949")
      end
    end
  end

  describe "#subsidiaries" do
    it "looks up subsidiaries" do
      subsidiaries = [
        { "internalId" => "1", "name" => "Apple" },
        { "internalId" => "2", "name" => "Banana" }
      ]
      stub_request(
        :get,
        "https://api.cloud-elements.com/elements/api-v2" \
        "/hubs/erp/lookups/subsidiary"
      ).
        with(
          headers: {
            "Authorization" => "User user-secret, " \
            "Organization org-secret, " \
            "Element element-secret",
            "Content-Type" => "application/json"
          }
        ).
        to_return(status: 200, body: subsidiaries.to_json)

      result = client.subsidiaries

      expect(result.to_a).to eq(subsidiaries)
    end
  end

  describe "#employees" do
    let(:expected_headers) do
      {
        "Authorization" => "User user-secret, " \
        "Organization org-secret, " \
        "Element element-secret",
        "Content-Type" => "application/json"
      }
    end

    it "looks up employees" do
      stub_request(
        :get,
        "https://api.cloud-elements.com/elements/api-v2" \
        "/hubs/erp/employees" \
        "?where=subsidiary%3D1"
      ).
        with(headers: expected_headers).
        to_return(status: 200, body: namely_fixture('net_suite_employees'))

      result = client.employees(1)

      expect(result.count).to eq(5)
      expect(result).to all(be_kind_of(Hash))
    end

    it "paginates through employees on Cloud Elements" do
      next_page_token = "I_am_a_token_rwar"
      first_page_request = stub_request(:get, "https://api.cloud-elements.com/elements/api-v2/hubs/erp/employees?where=subsidiary%3D1").
        with(headers: expected_headers).
        to_return(
          status: 200,
          body: [ internalId: "ohhai" ].to_json,
          headers: {
            "Elements-Next-Page-Token" => next_page_token,
          })

      second_page_request = stub_request(:get, "https://api.cloud-elements.com/elements/api-v2/hubs/erp/employees?nextPage=#{next_page_token}&where=subsidiary%3D1").
        with(headers: expected_headers).
        to_return(status: 200, body: [ internalId: "haioh" ].to_json)

      employees = client.employees(1)

      expect(employees.count).to be(2)
      expect(employees).to all(be_kind_of(Hash))
      expect(
        employees.map {|h| h['internalId'] }
      ).to match_array(['ohhai', 'haioh'])

      expect(first_page_request).to have_been_requested
      expect(second_page_request).to have_been_requested
    end
  end

  describe "#profile_fields" do
    it "gets a currest list of NetSuite employee profile fields" do
      fields = [
        double(:employee_field),
        double(:employee_field)
      ]

      fields_loader = instance_spy(
        NetSuite::EmployeeFieldsLoader,
        load_profile_fields: fields
      )

      netsuite_client = client

      allow(NetSuite::EmployeeFieldsLoader).to receive(:new).
        with(request: netsuite_client.request).
        and_return(fields_loader)

      expect(netsuite_client.profile_fields).to match_array(fields)
    end
  end

  def client
    NetSuite::Client.new(
      user_secret: "user-secret",
      organization_secret: "org-secret",
      partner_id: "partnerid",
      app_id: "appid",
      element_secret: "element-secret"
    )
  end
end
