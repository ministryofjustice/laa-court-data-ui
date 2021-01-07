# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class Hearing < Base
      acts_as_resource self

      has_many :providers
      property :defendant_names, default: []
    end
  end
end
