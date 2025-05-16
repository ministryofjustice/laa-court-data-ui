# frozen_string_literal: true

FactoryBot.define do
  # ActiveResource Factory, use :build not :create to prevent HTTP calls
  factory :cracked_ineffective_trial, class: 'Cda::BaseModel' do
    id { 'ae6e536e-2173-4a89-8254-a2ccd0051f84' }
    code { 'A' }
    description { 'Acceptable guilty plea(s) entered late to some or all charges' }
    type { 'cracked' }
    date { '2022-05-17T00:00:00.000Z' }
  end
end
