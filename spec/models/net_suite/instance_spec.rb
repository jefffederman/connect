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
          account_id: "42"
        )

        instance_hash = NetSuite::Instance.new(authentication).to_h
        config = instance_hash["configuration"]
        element = instance_hash["element"]

        expect(config["user.username"]).to eq authentication.email
        expect(config["user.password"]).to eq authentication.password
        expect(config["netsuite.accountId"]).to eq authentication.account_id
        expect(config["netsuite.sandbox"]).to eq false
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
