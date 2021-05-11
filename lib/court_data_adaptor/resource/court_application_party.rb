# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class CourtApplicationParty < Base
      acts_as_resource self
    end
  end
end
