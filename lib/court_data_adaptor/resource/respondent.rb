# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class Respondent < Base
      acts_as_resource self

      belongs_to :court_application

      property :respondent, type: :string
    end
  end
end
