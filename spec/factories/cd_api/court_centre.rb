# frozen_string_literal: true

FactoryBot.define do
  # ActiveResource Factory, use :build not :create to prevent HTTP calls
  factory :court_centre, class: 'CdApi::CourtCentre' do
    name { 'Nottingham' }
  end
end

