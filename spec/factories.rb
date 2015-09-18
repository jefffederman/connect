FactoryGirl.define do
  factory :attribute_mapper do
  end

  factory :field_mapping do
    attribute_mapper
    integration_field_name { integration_field_id.titleize }
    integration_field_id "firstName"
    namely_field_name "first_name"
  end

  factory :net_suite_connection, :class => 'NetSuite::Connection' do
    installation

    trait :connected do
      instance_id "123xy"
      authorization "abc12z"
      subsidiary_required true
    end

    trait :with_namely_field do
      found_namely_field true
    end

    trait :ready do
      connected
      with_namely_field
      subsidiary_id "45z"
    end
  end

  factory :icims_connection, class: "Icims::Connection" do
    installation

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
    installation

    trait :connected do
      api_key "MY_API_KEY"
      secret "MY_API_SECRET_SHHH"
    end

    trait :disconnected do
      api_key nil
      secret nil
    end

    trait :with_namely_field do
      found_namely_field true
    end
  end

  factory :greenhouse_connection, class: "Greenhouse::Connection" do
    installation

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

  factory :sync_summary do
    association :connection, factory: :net_suite_connection
  end

  factory :user do
    sequence(:namely_user_id) { |n| "NAMELY-USER-#{n}" }
    subdomain { installation.subdomain }
    access_token ENV.fetch("TEST_NAMELY_ACCESS_TOKEN")
    sequence(:refresh_token) { |n| "refresh-token-#{n}" }
    access_token_expiry { 15.minutes.from_now }
    email "integrationlover@example.com"
    association :installation, factory: :fixed_subdomain_installation
  end

  factory :installation do
    sequence(:subdomain) { |n| "subdomain#{n}" }

    factory :fixed_subdomain_installation do
      subdomain ENV.fetch("TEST_NAMELY_SUBDOMAIN")
    end
  end

  factory :profile_event do
    sync_summary
    sequence(:profile_id) { |n| "namely-#{n}-id" }
    profile_name "Example Name"
  end
end
