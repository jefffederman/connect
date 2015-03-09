require "rails_helper"

describe Netsuite::AttributeMapper do
  it "transforms a list of employees into an array of Hashes appropriate for
  the Namely API" do
    netsuite_employee = double(
      :netsuite_employee,
      email: "bdickens@ramsey.com",
      first_name: "Brandy",
      internal_id: "912",
      last_name: "Dickens",
      is_inactive: "false",
      gender: "female",
    )
    mapper = Netsuite::AttributeMapper.new

    expect(mapper.call([netsuite_employee])).to eq(
      [
        first_name: "Brandy",
        last_name: "Dickens",
        email: "bdickens@ramsey.com",
        netsuite_id: "912",
        user_status: "active",
        gender: "female",
      ]
    )
  end
end
