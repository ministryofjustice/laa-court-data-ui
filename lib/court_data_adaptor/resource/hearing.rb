# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class Hearing < Base
      acts_as_resource self

      has_many :providers
      has_many :hearing_events
      has_one :cracked_ineffective_trial

      property :court_name, type: :string
      property :defendant_names, default: []
      property :hearing_days, default: []
      property :hearing_type, type: :string
      property :id, type: :string
      property :judge_names, default: []
      property :prosecution_advocate_names, default: []
    end
  end
end
