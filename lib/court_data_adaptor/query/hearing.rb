# frozen_string_literal: true

module CourtDataAdaptor
  module Query
    class Hearing < Base
      acts_as_resource CourtDataAdaptor::Resource::Hearing

      def call
        refresh_token_if_required!

        resource
          .includes(:hearing_events, :providers)
          .find(hearing_id)
          .first
      end

      def hearing_id
        term
      end
    end
  end
end
