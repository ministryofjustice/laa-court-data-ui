# frozen_string_literal: true

module CdApi
  class ProsecutionCase < BaseModel
    belongs_to :hearing, class_name: 'CdApi::Hearing'
  end
end
