module CourtDataAdaptor
  module Resource
    class PleaSummary < V2
      def date
        super.to_date
      end

      def user_facing_value
        value.humanize
      end
    end
  end
end
