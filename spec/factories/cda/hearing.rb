# frozen_string_literal: true

FactoryBot.define do
  # ActiveResource Factory, use :build not :create to prevent HTTP calls
  factory :hearing, class: 'Cda::Hearing' do
    hearing { {} }
    shared_time { '2022-07-22T15:31:42.832Z[UTC]' }

    trait :with_hearing_details do
      hearing { association :hearing_details }
    end
  end

  factory :hearing_details, class: 'Cda::Hearing' do
    id { '79b9aced-83ec-4189-ae40-4db5b522cd67' }
    jurisdiction_type { 'MAGISTRATES' }
    court_centre { {} }
    hearing_language { 'ENGLISH' }
    has_shared_result { true }
    court_applications { [] }
    hearing_type { {} }
    hearing_days { [] }
    judiciary { [] }
    prosecution_counsels { [] }
    defence_counsels { [] }
    cracked_ineffective_trial { {} }
    prosecution_cases { [] }
    defendant_judicial_results { [] }
    defendant_attendance { [] }

    trait :with_hearing_days do
      after(:build) do |hearing|
        hearing_day1 = FactoryBot.build(:hearing_day, hearing:)
        hearing.hearing_days = [hearing_day1]
      end
    end

    trait :with_defence_counsels do
      defence_counsels { [build(:defence_counsels)] }
    end
  end
end
