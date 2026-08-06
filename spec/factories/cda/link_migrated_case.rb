# frozen_string_literal: true

FactoryBot.define do
  factory :link_migrated_case, class: 'Cda::LinkMigratedCase' do
    id { SecureRandom.uuid }
    case_urn { 'TEST12345' }
    defendant_id { 'def-1' }
    committal_date { nil }
    sent_date { Date.new(2024, 3, 1) }
    xhibit_case_number { 'X123' }
    court_name { 'Any Court' }
    process_errors { { 'message' => 'MAAT application not found' } }
  end
end
