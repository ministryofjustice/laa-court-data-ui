# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class Offence < Base
      acts_as_resource self

      belongs_to :defendant

      property :title, type: :string
      property :legislation, type: :string
      property :pleas, type: :plea_collection, default: []
      property :mode_of_trial, type: :string
      property :mode_of_trial_reasons, type: :mode_of_trial_reason_collection, default: []
    end
  end
end
