# frozen_string_literal: true

FactoryBot.define do
  # ActiveResource Factory, use :build not :create to prevent HTTP calls
  factory :judicial_results, class: 'CdApi::Defendant' do
    id { SecureRandom.uuid }
    label { 'Example Judicial Result' }
    ordered_date { '2021-10-22' }
    prompts { [] }

    trait :with_prompts do
      after(:build) do |prompts|
        new_prompt = FactoryBot.build(:prompts)
        prompts.prompts = [new_prompt]
      end
    end
  end

  factory :prompts, class: 'CdApi::Defendant' do
    type_id { 'fbed768b-ee95-4434-87c8-e81cbc8d24c8' }
    label { 'Next hearing in Crown Court' }
    value { "Test Label\nTest Label" }
  end
end
