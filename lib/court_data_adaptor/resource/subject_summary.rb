module CourtDataAdaptor
  module Resource
    class SubjectSummary < V2
      DUMMY_MAAT_PREFIX = "Z".freeze

      def name
        [defendant_first_name, defendant_last_name].join(" ")
      end

      def date_of_birth
        defendant_dob.to_date
      end

      def offence_summary
        @offence_summary ||= super.map { OffenceSummary.new(_1) }
      end

      def maat_reference
        different_maats = offence_summary.map(&:maat_reference).uniq
        if different_maats.count > 1
          Rails.logger.warn("Court application subject has multiple MAAT IDs - #{different_maats.to_sentence}")
          "Not available"
        else
          different_maats.reject { _1&.starts_with?(DUMMY_MAAT_PREFIX) }.first
        end
      end
    end
  end
end
