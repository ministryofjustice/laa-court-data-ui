# frozen_string_literal: true

module CourtDataAdaptor
  module Resource
    class Offence < Base
      belongs_to :defendant
    end
  end
end
