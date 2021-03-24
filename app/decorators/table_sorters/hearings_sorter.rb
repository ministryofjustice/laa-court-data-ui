# frozen_string_literal: true

module TableSorters
  class HearingsSorter
    def initialize(hearings, sort_order)
      @hearings = hearings
      @sort_order = sort_order
    end

    def sorted_hearing(hearing)
      hearing.hearing_days.map(&:to_datetime).sort
    end

    private

    def order_by_asc_or_desc(arr)
      return arr.reverse if @sort_order&.include? 'desc'
      arr
    end
  end
end
