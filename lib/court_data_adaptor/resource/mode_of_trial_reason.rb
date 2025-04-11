# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class ModeOfTrialReason < V1
      acts_as_resource self

      property :code, type: :string
      property :description, type: :string
    end
  end
end
