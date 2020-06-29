# frozen_string_literal: true

require 'faker/unlink_reason'

FactoryBot.define do
  factory :unlink_reason do
    code { rand(7) }
    description { Faker::UnlinkReason.description }
    text_required { [true, false].sample }
  end
end
