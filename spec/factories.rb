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

    trait :locked do
      locked true
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

  # These factories are not backed by a database
  factory :namely_profile, class: "Namely::Model" do
    id "123-123-123"
    first_name "Bob"
    last_name "Ross"
    middle_name "Happy Tree"
    email "bob.ross@namely.com"
    personal_email "bobross@pbs.org"
    home({})
    netsuite_id nil
    start_date "07/18/2013"
    gender "Female"
    home_phone "123-123-1234"

    initialize_with do
      Namely::Model.new(nil, {
        id: id,
        first_name: first_name,
        last_name: last_name,
        middle_name: middle_name,
        email: email,
        gender: gender,
        personal_email: personal_email,
        home: home.stringify_keys,
        netsuite_id: netsuite_id,
      })
    end
  end

  factory :netsuite_profile, class: Hash do
    first_name "Bob"
    last_name "Ross"
    middle_name "Happy Tree"
    email "bob.ross@namely.com"
    gender "_female"
    subsidiary_id "1066"
    subsidiary_name "Fake Subsidiary"
    phone "(123) 123-1234"
    id nil

    initialize_with do
      {
        "firstName" => first_name,
        "lastName" => last_name,
        "middleName" => middle_name,
        "email" => email,
        "phone" => phone,
        "gender" => { "value" => gender },
        "subsidiary" => { "internalId" => subsidiary_id, "name" => subsidiary_name },
        "internalId" => id,
      }
    end
  end
end
