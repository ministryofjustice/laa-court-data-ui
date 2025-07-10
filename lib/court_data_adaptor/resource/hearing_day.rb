module CourtDataAdaptor
  module Resource
    class HearingDay < V2
      attr_accessor :hearing

      def day_string
        sitting_day.to_date.to_fs(:day_month_year)
      end

      def time_string
        sitting_day.to_time.strftime('%H:%M')
      end

      def date
        sitting_day.to_date
      end
    end
  end
end
