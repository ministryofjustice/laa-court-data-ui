# frozen_string_literal: true

FactoryBot.define do
  # ActiveResource Factory, use :build not :create to prevent HTTP calls
  factory :prosecution_case, class: 'Cda::ProsecutionCase' do
    prosecution_case_reference { 'THECASEURN' }
    hearing_summaries { [] }
    defendant_summaries { [] }

    trait :with_defendant_summaries do
      after(:build) do |prosecution_case|
        defendant1 = FactoryBot.build(:defendant_summary, prosecution_case:)
        defendant2 = FactoryBot.build(:defendant_summary, prosecution_case:)
        prosecution_case.defendant_summaries = [defendant1, defendant2]
      end
    end

    trait :with_hearing_summaries do
      after(:build) do |prosecution_case|
        prosecution_case.hearing_summaries = [FactoryBot.build(:hearing_summary, :with_hearing_days)]
      end
    end
  end
end
