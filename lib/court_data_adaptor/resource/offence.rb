# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class Offence < Base
      acts_as_resource self

      belongs_to :defendant

      property :title, type: :string
      property :plea, type: :string
      property :plea_date, type: :string
      property :mode_of_trial, type: :string
      property :mode_of_trial_reason, type: :string
    end
  end
end
