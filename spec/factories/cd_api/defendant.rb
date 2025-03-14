# frozen_string_literal: true

FactoryBot.define do
  # ActiveResource Factory, use :build not :create to prevent HTTP calls
  factory :defendant, class: 'CdApi::Defendant' do
    id { SecureRandom.uuid }
    national_insurance_number { 'AP662165A' }
    arrest_summons_number { 'BXIM1ECIO3JH' }
    name { 'Jammy Edward Dodger' }
    first_name { 'Jammy' }
    middle_name { 'Edward' }
    last_name { 'Dodger' }
    date_of_birth { '1994-03-02' }
    proceedings_concluded { false }
    representation_order { {} }
    prosecution_case_reference { 'PKTEST22345' }

    trait :with_offence_summaries do
      offence_summaries { [build(:offence_summary)] }
    end
  end
end
