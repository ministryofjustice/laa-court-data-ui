# frozen_string_literal: true

FactoryBot.define do
  # ActiveResource Factory, use :build not :create to prevent HTTP calls
  factory :hearing_day, class: 'Cda::BaseModel' do
    sitting_day { DateTime.parse('2021-01-19T10:45:00.000Z') }
    listing_sequence { nil }
    listed_duration_minutes { 167 }
    has_shared_results { true }
    defence_counsels { [] }
  end
end
