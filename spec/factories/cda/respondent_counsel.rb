FactoryBot.define do
  # ActiveResource Factory, use :build not :create to prevent HTTP calls
  factory :respondent_counsel, class: 'Cda::BaseModel' do
    hearing_details

    title { 'Mr' }
    first_name { 'John' }
    middle_name { '' }
    last_name { 'Smith' }
    status { 'Junior' }
    attendance_days { [] }
  end
end
