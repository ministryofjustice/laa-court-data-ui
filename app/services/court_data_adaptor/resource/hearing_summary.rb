# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class HearingSummary < Base
      acts_as_resource self
    end
  end
end
