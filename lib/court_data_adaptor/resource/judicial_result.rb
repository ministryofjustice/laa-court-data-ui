# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class JudicialResult < V1
      acts_as_resource self

      belongs_to :court_application

      property :text, type: :string
      property :cjs_code, type: :string
    end
  end
end
