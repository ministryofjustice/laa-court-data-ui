module CourtDataAdaptor
  module Resource
    class ApplicationHearing < V2
      def hearing_days
        @hearing_days ||= super.map do |day_payload|
          HearingDay.new(day_payload).tap { _1.hearing = self }
        end
      end

      def defence_counsels
        @defence_counsels ||= super.map { DefenceCounsel.new(_1) }
      end

      def defence_counsels_on(date)
        defence_counsels.select { _1.attended_on?(date) }
      end

      def court_centre
        @court_centre ||= CourtCentre.new(super)
      end
    end
  end
end
