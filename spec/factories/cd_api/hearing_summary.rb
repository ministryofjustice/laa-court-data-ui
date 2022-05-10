# frozen_string_literal: true

FactoryBot.define do
  # ActiveResource Factory, use :build not :create to prevent HTTP calls
  factory :hearing_summary, class: 'CdApi::HearingSummary' do
    hearing_type { 'Trial' }
    hearing_days { [] }
    defence_counsels { [] }

    trait :with_hearing_days do
      hearing_day1 = FactoryBot.build :hearing_day
      hearing_days { [hearing_day1] }
    end

    trait :with_defence_counsels do
      defence_counsel1 = FactoryBot.build :defence_counsel
      defence_counsel2 = FactoryBot.build :defence_counsel
      defence_counsels { [defence_counsel1, defence_counsel2] }
    end
  end
end
