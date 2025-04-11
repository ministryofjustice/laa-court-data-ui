# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class HearingEvent < V1
      acts_as_resource self

      belongs_to :hearing

      property :description, type: :string
      property :occurred_at, type: :time
      property :note, type: :string
    end
  end
end
