# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class V1 < Base
      API_VERSION = 1
      include ResourceConfiguration
    end
  end
end
