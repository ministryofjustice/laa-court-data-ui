# frozen_string_literal: true

FactoryBot.define do
  # ActiveResource Factory, use :build not :create to prevent HTTP calls
  factory :overall_defendant, class: 'CdApi::OverallDefendant' do
    case_summary

    id { '29d1db1c-1467-4304-aa5b-904044a1afe3' }
    first_name { 'John' }
    middle_name { 'Apple' }
    last_name { 'Smith' }
    arrest_summons_number { 'R74BJ3VVK7BE' }
    date_of_birth { '1978-12-10' }
    national_insurance_number { 'XE123410C' }
    maat_reference { 1_234_567 }

    trait :with_hearing_days do
      hearing_days { build :hearing_days }
    end
  end
end
