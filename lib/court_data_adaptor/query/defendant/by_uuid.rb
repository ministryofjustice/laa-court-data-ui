# frozen_string_literal: true

module CourtDataAdaptor
  module Query
    module Defendant
      class ByUuid < Base
        acts_as_resource CourtDataAdaptor::Resource::Defendant

        def make_request
          refresh_token_if_required!
          resource
            .includes('offences')
            .find(id)
            .first
        end

        private

        def id
          term
        end
      end
    end
  end
end
