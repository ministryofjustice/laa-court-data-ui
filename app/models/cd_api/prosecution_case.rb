# frozen_string_literal: true

module CdApi
  class ProsecutionCase < BaseModel
      self.element_name = 'hearingsummaries'
      attr_accessor :day
  end
end