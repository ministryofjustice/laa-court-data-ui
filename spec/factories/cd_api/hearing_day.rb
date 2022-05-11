# frozen_string_literal: true

FactoryBot.define do
  # ActiveResource Factory, use :build not :create to prevent HTTP calls
  factory :hearing_day, class: 'CdApi::HearingDay' do
    sitting_day { '2021-01-19T10:45:00.000Z' }
  end
end
