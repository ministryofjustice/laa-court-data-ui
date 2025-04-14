# frozen_string_literal: true

FactoryBot.define do
  # ActiveResource Factory, use :build not :create to prevent HTTP calls
  factory :application_summary, class: 'CdApi::ApplicationSummary' do
    id { 'f38d0030-0b4a-4fa5-9484-bb37b1e6ab39' }
    short_id { 'A25ULRHLVC7S' }
    reference { 'Assisting prisoners to escape' }
    title { 'Firearms Act 1968 s.3' }
    received_date { '2019-10-17' }
  end
end
