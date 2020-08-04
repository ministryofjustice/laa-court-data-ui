# frozen_string_literal: true

module CourtDataAdaptor
  module Query
    module Defendant
      class ByUuid < Base
        acts_as_resource CourtDataAdaptor::Resource::Defendant

        def call
          refresh_token_if_required!

          resource
            .find(defendant_id)
            .first

        end

        private

        def defendant_id
          term
        end
      end
    end
  end
end
