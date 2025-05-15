# frozen_string_literal: true

FactoryBot.define do
  # ActiveResource Factory, use :build not :create to prevent HTTP calls
  factory :defence_counsel, class: 'Cda::BaseModel' do
    title { 'Mr' }
    first_name { 'John' }
    middle_name { '' }
    last_name { 'Smith' }
    status { 'Junior' }
    attendance_days { [] }
    defendants { [] }
  end
end
