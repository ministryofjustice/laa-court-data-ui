# frozen_string_literal: true

module TableSorters
  class HearingsDateSorter < HearingsSorter
    def sorted_hearings
      order_by_asc_or_desc(@hearings.sort_by { |h| h.hearing_days.map(&:to_datetime) })
    end

    def sorted_hearing(hearing)
      order_by_asc_or_desc(super)
    end
  end
end
