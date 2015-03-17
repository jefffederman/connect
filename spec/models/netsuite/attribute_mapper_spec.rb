require "rails_helper"

describe Netsuite::AttributeMapper do
  describe ".call" do
    it "transforms a Netsuite employee into hash for the Namely API" do
      netsuite_employee = JSON.parse(
        File.read("spec/fixtures/api_responses/netsuite_employee.json")
      )
      mapper = Netsuite::AttributeMapper.new

      expect(mapper.call(netsuite_employee)).to eq(
        {
          first_name: "Brandy",
          last_name: "Dickens",
          email: "bdickens@ramsey.com",
          netsuite_id: "912",
          user_status: "active",
          gender: "female",
        }
      )
    end
  end
end
