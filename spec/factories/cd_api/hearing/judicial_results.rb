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
end
