# frozen_string_literal: true

FactoryBot.define do
  # ActiveResource Factory, use :build not :create to prevent HTTP calls
  factory :laa_application, class: 'Cda::BaseModel' do
    reference { '' }
    status_code { 'AP' }
    description { '' }
    status_date { '2022-08-02' }
    effective_start_date { nil }
    effective_end_date { nil }
    contract_number { nil }
  end
end
