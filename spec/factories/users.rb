# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    email_confirmation { email }
    password { 'testing123' }
    password_confirmation { 'testing123' }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    roles { ['caseworker'] }

    trait :with_caseworker_role do
      roles { ['caseworker'] }
    end

    trait :with_manager_role do
      roles { ['manager'] }
    end

    trait :with_caseworker_manager_role do
      roles { %w[caseworker manager] }
    end

    trait :with_caseworker_manager_admin_role do
      roles { %w[caseworker manager admin] }
    end

    trait :with_admin_role do
      roles { %w[admin] }
    end
  end
end
