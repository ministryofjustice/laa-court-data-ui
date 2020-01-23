# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'testing123' }
    password_confirmation { 'testing123' }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    roles { ['caseworker'] }
  end
end
