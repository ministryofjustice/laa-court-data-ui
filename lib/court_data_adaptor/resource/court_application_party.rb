# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class CourtApplicationParty < V1
      acts_as_resource self

      belongs_to :court_application

      property :synonym, type: :string
    end
  end
end
