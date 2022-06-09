# frozen_string_literal: true

module CdApi
  class CourtCentre < BaseModel
    belongs_to :hearing_summary

    attr_accessor :name
  end
end
