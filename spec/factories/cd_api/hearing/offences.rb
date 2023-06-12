# frozen_string_literal: true

FactoryBot.define do
  # ActiveResource Factory, use :build not :create to prevent HTTP calls
  factory :hearing_offences, class: 'CdApi::Defendant' do
    id { SecureRandom.uuid }
    judicial_results { [] }

    trait :with_judicial_results do
      after(:build) do |offences|
        result = FactoryBot.build(:judicial_results)
        offences.judicial_results = [result]
      end
    end
  end
end
