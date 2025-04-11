module CourtDataAdaptor
  module Resource
    class SubjectSummary < V2
      def name
        [defendant_first_name, defendant_last_name].join(" ")
      end

      def date_of_birth
        defendant_dob.to_date
      end

      def maat_reference
        representation_order["application_reference"]
      end
    end
  end
end
