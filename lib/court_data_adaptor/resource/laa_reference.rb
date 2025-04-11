# frozen_string_literal: true

# See defendant attributes:
# here https://github.com/ministryofjustice/laa-court-data-adaptor/blob/master/schema/schema.json
#
module CourtDataAdaptor
  module Resource
    class LaaReference < V1
      acts_as_resource self
    end
  end
end
