# frozen_string_literal: true

FactoryBot.define do
  # ActiveResource Factory, use :build not :create to prevent HTTP calls
  factory :hearing_person_details, class: 'Cda::BaseModel' do
    hearing_details

    title { 'Mr' }
    first_name { 'Vince' }
    middle_name { '' }
    last_name { 'James' }
    date_of_birth { '1980-11-11' }
    gender { 'MALE' }
    documentation_language_needs { 'ENGLISH' }
    nino { '' }
    occupation { nil }
    occupation_code { nil }
  end
end
