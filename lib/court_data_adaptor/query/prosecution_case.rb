# frozen_string_literal: true

module CourtDataAdaptor
  module Query
    class ProsecutionCase < Base
      acts_as_resource CourtDataAdaptor::Resource::ProsecutionCase

      def call
        refresh_token_if_required!

        resource
          .includes(:defendants,
                    'defendants.offences',
                    :hearing_summaries,
                    :hearings,
                    'hearings.hearing_events',
                    'hearings.providers',
                    'hearings.cracked_ineffective_trial')
          .where(prosecution_case_reference: urn)
          .all
      end

      private

      def urn
        term.delete("\s\t\r\n\/\-").upcase
      end
    end
  end
end
