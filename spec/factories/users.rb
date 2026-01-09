# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    email_confirmation { email }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    username { "#{last_name.delete('\'')[0, 4]}-#{first_name.delete('\'')[0, 1]}#{rand(99)}".downcase }
    roles { ['caseworker'] }

    trait :with_caseworker_role do
      roles { ['caseworker'] }
    end

    trait :with_caseworker_role do
      roles { %w[caseworker] }
    end

    trait :with_caseworker_admin_role do
      roles { %w[caseworker admin] }
    end

    trait :with_admin_role do
      roles { %w[admin] }
    end

    trait :with_data_analyst do
      roles { %w[data_analyst] }
    end
  end
end
