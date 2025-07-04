# frozen_string_literal: true

FactoryBot.define do
  # ActiveResource Factory, use :build not :create to prevent HTTP calls
  factory :defendant_summary, class: 'Cda::DefendantSummary' do
    prosecution_case

    id { '29d1db1c-1467-4304-aa5b-904044a1afe3' }
    first_name { 'John' }
    middle_name { 'Apple' }
    last_name { 'Smith' }
    arrest_summons_number { 'R74BJ3VVK7BE' }
    date_of_birth { '1978-12-10' }
    national_insurance_number { 'XE123410C' }
    offence_summaries { [build(:offence_summary, :with_laa_application)] }

    trait :with_hearing_days do
      hearing_days { association :hearing_days }
    end
  end
end
