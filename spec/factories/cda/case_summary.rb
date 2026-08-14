# frozen_string_literal: true

FactoryBot.define do
  factory :case_summary, class: 'Cda::CaseSummary' do
    case_status { 'ACTIVE' }
    prosecution_case_id { '2c646634-9f24-42fd-865e-ef1e282b5953' }
    prosecution_case_reference { 'EPAYAQECKM' }
  end
end
