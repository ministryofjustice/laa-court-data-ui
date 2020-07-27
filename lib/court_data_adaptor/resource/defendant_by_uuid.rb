module CourtDataAdaptor
    module Resource
      class DefendantByUuid < Base
        acts_as_resource defendant
      end
    end
  end
  