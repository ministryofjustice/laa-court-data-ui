# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class Hearing < Base
      acts_as_resource self
    end
  end
end
