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
        offence_summary.map(&:maat_reference).uniq.reject { _1&.starts_with?(DUMMY_MAAT_PREFIX) }.compact.join
      end

      def maat_linked?
        maat_reference.present?
      end
    end
  end
end
