# frozen_string_literal: true

module CdApi
  class Hearing < BaseModel
    has_one :cracked_ineffective_trial, class_name: 'cd_api/cracked_ineffective_trial'
    has_many :prosecution_case, class_name: 'cd_api/prosecution_case'
  end
end
