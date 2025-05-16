# frozen_string_literal: true

FactoryBot.define do
  # ActiveResource Factory, use :build not :create to prevent HTTP calls
  factory :hearing_defendant_details, class: 'Cda::BaseModel' do
    hearing_details
    person_details { {} }
    arrest_summons_number { 'D28GC01122381937' }
    bail_conditions { '' }
    bail_status { {} }

    trait :with_person_details do
      person_details { association :hearing_person_details }
    end
  end
end
