# frozen_string_literal: true

FactoryBot.define do
  # ActiveResource Factory, use :build not :create to prevent HTTP calls
  factory :hearing_prosecution_case, class: 'CdApi::ProsecutionCase' do
    hearing_details

    id { SecureRandom.uuid }
    prosecution_case_identifier { {} }
    status { 'INACTIVE' }
    statement_of_facts { 'Fuga laudantium tenetur next level et.' }
    statement_of_facts_welsh { 'Meh pug error et non' }
    defendants { [] }
  end
end
