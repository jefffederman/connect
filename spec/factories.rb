FactoryGirl.define do
  factory :attribute_mapper do
    mapping_direction "export"
    user
  end

  factory :field_mapping do
    attribute_mapper
    integration_field_name "firstName"
    namely_field_name "first_name"
  end

  factory :net_suite_connection, :class => 'NetSuite::Connection' do
    user

    trait :connected do
      instance_id "123xy"
      authorization "abc12z"
    end

    trait :with_namely_field do
      found_namely_field true
    end
  end

  factory :icims_connection, class: "Icims::Connection" do
    user

    trait :connected do
      customer_id 2187
      username "crashoverride"
      key "riscisgood"
    end

    trait :with_namely_field do
      found_namely_field true
    end
  end

  factory :jobvite_connection, class: "Jobvite::Connection" do
    user

    trait :connected do
      api_key "MY_API_KEY"
      secret "MY_API_SECRET_SHHH"
    end

    trait :disconnected do
      api_key nil
      secret nil
    end
  end

  factory :greenhouse_connection, class: "Greenhouse::Connection" do
    user

    trait :connected do
      name "MY NAME"
      secret_key "MY_TOKEN"
    end

    trait :disconnected do
      name nil
      secret_key nil
    end

    trait :with_namely_field do
      found_namely_field true
    end
  end

  factory :user do
    sequence(:namely_user_id) { |n| "NAMELY-USER-#{n}" }
    subdomain ENV.fetch("TEST_NAMELY_SUBDOMAIN")
    access_token ENV.fetch("TEST_NAMELY_ACCESS_TOKEN")
    sequence(:refresh_token) { |n| "refresh-token-#{n}" }
    access_token_expiry { 15.minutes.from_now }
    email "integrationlover@example.com"
  end
end
