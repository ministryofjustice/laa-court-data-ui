# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class CourtApplicationType < V1
      acts_as_resource self

      belongs_to :court_application

      property :description, type: :string
      property :code, type: :string
      property :category_code, type: :string
      property :legislation, type: :string
      property :applicant_appellant_flag, type: :boolean
      property :id, type: :string
    end
  end
end
