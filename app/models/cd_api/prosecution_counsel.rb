# frozen_string_literal: true

module CdApi
  class ProsecutionCounsel < BaseModel
    belongs_to :hearing
  end
end
