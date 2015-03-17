require "rails_helper"

describe Netsuite::AttributeMapper do
  describe ".call" do
    it "transforms a Netsuite employee into hash for the Namely API" do
      netsuite_employee = double(
        Netsuite::Employee,
        "first_name" => "Brandy",
        "last_name" => "Dickens",
        "email" => "bdickens@ramsey.com",
        "internal_id" => "912",
        "is_inactive" => "false",
        "gender" => "female"
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
