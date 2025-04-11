# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class Hearing < V1
      acts_as_resource self

      has_many :providers
      has_many :hearing_events
      has_one :cracked_ineffective_trial
      has_many :court_applications

      property :court_name, type: :string
      property :day
      property :defendant_names, default: []
      property :hearing_days, default: []
      property :hearing_type, type: :string
      property :id, type: :string
      property :judge_names, default: []
      property :prosecution_advocate_names, default: []
    end
  end
end
