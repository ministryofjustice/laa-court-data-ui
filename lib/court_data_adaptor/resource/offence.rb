# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class Offence < Base
      acts_as_resource self

      belongs_to :defendant
    end
  end
end
