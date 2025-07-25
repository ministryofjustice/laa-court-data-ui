module CourtDataAdaptor
  module Resource
    class OffenceSummary < V2
      def maat_reference
        laa_application["reference"]
      end
    end
  end
end
