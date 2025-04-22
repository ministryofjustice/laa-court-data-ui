module CourtDataAdaptor
  module Resource
    class OffenceSummary < V2
      def maat_reference
        laa_application["reference"]
      end

      def pleas
        @pleas ||= super.map { PleaSummary.new(_1) }
      end
    end
  end
end
