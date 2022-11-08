# frozen_string_literal: true

FactoryBot.define do
  # ActiveResource Factory, use :build not :create to prevent HTTP calls
  factory :case_summary, class: 'CdApi::CaseSummary' do
    prosecution_case_reference { 'THECASEURN' }
    hearing_summaries { [] }
    overall_defendants { [] }

    trait :with_overall_defendants do
      after(:build) do |case_summary|
        defendant1 = FactoryBot.build(:overall_defendant, case_summary:)
        defendant2 = FactoryBot.build(:overall_defendant, case_summary:)
        case_summary.overall_defendants = [defendant1, defendant2]
      end
    end

    trait :with_hearing_summaries do
      after(:build) do |case_summary|
        case_summary.hearing_summaries = [FactoryBot.build(:hearing_summary, :with_hearing_days)]
      end
    end
  end
end
