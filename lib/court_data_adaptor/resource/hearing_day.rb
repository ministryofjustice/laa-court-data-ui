module CourtDataAdaptor
  module Resource
    class HearingDay < V2
      attr_accessor :hearing

      def day_string
        sitting_day.to_date.strftime('%d/%m/%Y')
      end

      def date
        sitting_day.to_date
      end
    end
  end
end
