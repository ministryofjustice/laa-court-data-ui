# frozen_string_literal: true

FactoryBot.define do
  # ActiveResource Factory, use :build not :create to prevent HTTP calls
  factory :offence_summary, class: 'CdApi::OffenceSummary' do
    code { 'PT00011' }
    order_index { 1 }
    title { 'Assisting prisoners to escape' }
    legislation { 'Firearms Act 1968 s.3' }
    wording { 'Random string' }
    arrest_date { '2019-10-17' }
    charge_date { '2019-10-17' }
    mode_of_trial { 'Summary offence' }
    start_date { '2019-10-17' }
    proceedings_concluded { false }
    pleas { [] }
    verdict { {} }
    laa_application { {} }

    trait :with_laa_application do
      laa_application { build :laa_application }
    end
  end
end
