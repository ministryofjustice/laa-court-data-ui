# frozen_string_literal: true

FactoryBot.define do
  # ActiveResource Factory, use :build not :create to prevent HTTP calls
  factory :case_summary, class: 'CdApi::CaseSummary' do
    hearing_summaries { [] }
    overall_defendants { [] }

    trait :with_overall_defendants do
      after(:build) do |case_summary|
        defendant1 = FactoryBot.build :overall_defendant, case_summary: case_summary
        defendant2 = FactoryBot.build :overall_defendant, case_summary: case_summary
        case_summary.overall_defendants = [defendant1, defendant2]
      end
    end
  end
end
