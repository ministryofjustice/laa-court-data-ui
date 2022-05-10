# frozen_string_literal: true

FactoryBot.define do
  # ActiveResource Factory, use :build not :create to prevent HTTP calls
  factory :prosecution_case, class: 'CdApi::ProsecutionCase' do
    hearing_summaries { [] }
    overall_defendants { [] }

    trait :with_overall_defendants do
      defendant1 = FactoryBot.build(:overall_defendant)
      defendant2 = FactoryBot.build(:overall_defendant)
      overall_defendants { [defendant1, defendant2] }
    end
  end
end
