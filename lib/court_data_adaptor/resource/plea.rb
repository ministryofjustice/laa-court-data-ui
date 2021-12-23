# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class Plea < Base
      acts_as_resource self

      property :code, type: :string
      property :pleaded_at, type: :string
      property :originating_hearing_id, type: :string
    end
  end
end
