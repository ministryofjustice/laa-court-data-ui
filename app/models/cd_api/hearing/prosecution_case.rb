# frozen_string_literal: true

module CdApi
  class Hearing::ProsecutionCase < BaseModel
    belongs_to :hearing
  end
end
