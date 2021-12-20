# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class Offence < Base
      acts_as_resource self

      belongs_to :defendant

      has_many :mode_of_trial_reasons
      has_many :pleas

      property :title, type: :string
      property :legislation, type: :string
      property :mode_of_trial, type: :string
    end
  end
end
