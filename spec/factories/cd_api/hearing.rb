# frozen_string_literal: true

FactoryBot.define do
  # ActiveResource Factory, use :build not :create to prevent HTTP calls
  factory :hearing, class: 'CdApi::Hearing' do
    id { '79b9aced-83ec-4189-ae40-4db5b522cd67' }
    hearing_type { 'Application to Break Fixture (BFA)' }
    estimated_duration { nil }
    defendants { [] }
    jurisdiction_type { 'MAGISTRATES' }
    type { 'cracked' }
    date { '2022-05-17T00:00:00.000Z' }
    court_centre { nil }
    defence_counsels { [] }
    hearing_days { [] }

    trait :with_hearing_days do
      after(:build) do |hearing|
        hearing_day1 = FactoryBot.build :hearing_day, hearing: hearing
        hearing.hearing_days = [hearing_day1]
      end
    end
  end
end
