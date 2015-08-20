require "rails_helper"

describe NetSuite::Client do
  describe ".from_env" do
    it "finds authorization from the environment" do
      env = {
        "CLOUD_ELEMENTS_USER_SECRET" => "user-secret",
        "CLOUD_ELEMENTS_ORGANIZATION_SECRET" => "org-secret"
      }

      ClimateControl.modify env do
        stub_request(:post, /.*/)
        client = NetSuite::Client.from_env

        client.create_instance({})

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
      stub_request(:post, /.*/)
      client = NetSuite::Client.new(
        user_secret: "user-secret",
        organization_secret: "org-secret",
      )

      client.
        authorize("element-secret").
        create_instance({})

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
        instance = { "id" => "123", "token" => "abcxyz" }
        stub_request(
          :post,
          "https://api.cloud-elements.com/elements/api-v2/instances"
        ).
          with(
            body: {
              configuration: {
                "user.username" => "u@example.com",
                "user.password" => "secret",
                "netsuite.accountId" => "123",
                "netsuite.sandbox" => false
              },
              "element" => {
                "key" => "netsuiteerp"
              },
              "tags" => [],
              "name" => "123_netsuite"
            }.to_json,
            headers: {
              "Authorization" => "User user-secret, Organization org-secret",
              "Content-Type" => "application/json"
            }
          ).
          to_return(status: 200, body: instance.to_json)

        client = NetSuite::Client.new(
          user_secret: "user-secret",
          organization_secret: "org-secret"
        )

        result = client.create_instance(
          email: "u@example.com",
          password: "secret",
          account_id: "123"
        )

        expect(result).to be_success
        expect(result[:id]).to eq("123")
        expect(result[:token]).to eq("abcxyz")
      end
    end

    context "on HTTP failure" do
      it "returns failure messages" do
        error = "a failure"
        stub_request(
          :post,
          "https://api.cloud-elements.com/elements/api-v2/instances"
        ).
          to_return(status: 400, body: { message: error }.to_json)

        client = NetSuite::Client.new(
          user_secret: "x",
          organization_secret: "x"
        )

        result = client.create_instance({})

        expect(result).not_to be_success
        expect(result[:message]).to eq(error)
      end
    end

    context "on authentication failure" do
      it "raises an Unauthorized exception" do
        error = "Invalid Organization or User secret, or invalid Element" \
                " token provided."

        stub_request(
          :post,
          "https://api.cloud-elements.com/elements/api-v2/instances"
        ).
          to_return(status: 401, body: { message: error }.to_json)

        client = NetSuite::Client.new(
          user_secret: "x",
          organization_secret: "x"
        )

        expect { client.create_instance({}) }.to raise_error(Unauthorized)
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

        expect(result).to be_success
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

        expect(result).to be_success
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

      expect(result).to be_success
      expect(result.to_a).to eq(subsidiaries)
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
      element_secret: "element-secret"
    )
  end
end
