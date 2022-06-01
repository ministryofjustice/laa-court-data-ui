# frozen_string_literal: true

module CdApi
  class Hearing < BaseModel
    self.collection_name = :hearing
    has_one :cracked_ineffective_trial, class_name: 'cd_api/cracked_ineffective_trial'
  end
end
