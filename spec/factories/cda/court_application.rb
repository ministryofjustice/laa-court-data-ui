# frozen_string_literal: true

FactoryBot.define do
  factory :court_application, class: 'Cda::CourtApplication' do
    application_category { 'appeal' }
    linked_maat_id { '1234567' }
    application_id { 'd174af7f-75da-428b-9875-c823eb182a23' }
    short_id { 'A25LO1OU0KE3' }
    application_reference { 'MyString' }
    application_status { 'DRAFT' }
    application_title { 'Appeal against a conviction' }
    application_type { 'String' }
    received_date { '2025-04-11' }

    case_summary { FactoryBot.build(:case_summary) }
    hearing_summary { [FactoryBot.build(:hearing_summary)] }
    subject_summary { FactoryBot.build(:subject_summary) }
  end
end
