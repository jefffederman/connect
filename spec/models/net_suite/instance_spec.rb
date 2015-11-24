require "rails_helper"

describe NetSuite::Instance do
  describe "#to_h" do
    it "returns a hash usable for instance creation" do
      Timecop.freeze do
        rails_env = "environment"
        allow(Rails).to receive(:env).and_return(rails_env)
        authentication = double(
          NetSuite::Authentication,
          email: "test@example.com",
          password: "sekret",
          account_id: "42",
          app_id: "appid",
          partner_id: "partnerid",
          company_id: "coid",
          user_id: "userid",
        )

        instance_hash = NetSuite::Instance.new(authentication: authentication).to_h
        config = instance_hash["configuration"]
        element = instance_hash["element"]

        expect(config["user.username"]).to eq authentication.email
        expect(config["user.password"]).to eq authentication.password
        expect(config["netsuite.accountId"]).to eq authentication.account_id
        expect(config["netsuite.sandbox"]).to eq false
        expect(config["netsuite.appId"]).to eq "appid"
        expect(config["netsuite.sso.roleId"]).to eq "3"
        expect(config["netsuite.sso.companyId"]).to eq "#{authentication.account_id}_coid"
        expect(config["netsuite.sso.userId"]).to eq "#{authentication.account_id}_userid"
        expect(config["netsuite.sso.partnerId"]).to eq "partnerid"
        expect(element["key"]).to eq "netsuiteerp"
        expect(instance_hash["tags"]).to eq []
        expect(instance_hash["name"]).to eq(
          "#{rails_env}_" \
          "#{Time.current.to_s(:number)}_" \
          "#{authentication.account_id}_" \
          "netsuite"
        )
      end
    end
  end
end
