# frozen_string_literal: true

FactoryBot.define do
  # ActiveResource Factory, use :build not :create to prevent HTTP calls
  factory :hearing_defendant, class: 'Cda::BaseModel' do
    hearing_details

    id { SecureRandom.uuid }
    prosecution_case_id { '' }
    offences { [] }
    defence_organisation { {} }
    defendant_details { {} }
    judicial_results { [] }
    legal_aid_status { nil }
    proceedings_concluded { nil }
    isYouth { nil }

    trait :with_defendant_details do
      defendant_details { association :hearing_defendant_details, :with_person_details }
    end
  end
end
