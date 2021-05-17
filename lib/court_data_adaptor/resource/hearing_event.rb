# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class HearingEvent < Base
      acts_as_resource self

      belongs_to :hearing

      property :description, type: :string
      property :occurred_at, type: :time
    end
  end
end
