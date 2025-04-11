# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class CrackedIneffectiveTrial < V1
      acts_as_resource self

      belongs_to :hearing

      property :id, type: :string
      property :type, type: :string
      property :code, type: :string
      property :description, type: :string
    end
  end
end
