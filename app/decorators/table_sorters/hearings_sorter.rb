# frozen_string_literal: true

module TableSorters
  class HearingsSorter
    def initialize(hearings, sort_order)
      @hearings = hearings
      @sort_order = sort_order
    end

    def sorted_hearings
      order_by_asc_or_desc(@hearings.sort_by { |h| h.hearing_days.map(&:to_datetime) })
    end

    def sorted_hearing(hearing)
      if @sort_order.eql?('date_desc')
        hearing.hearing_days.map(&:to_datetime).sort.reverse
      else
        hearing.hearing_days.map(&:to_datetime).sort
      end
    end

    private

    def order_by_asc_or_desc(sorted_hearings)
      sorted_hearings.reverse! if @sort_order&.include? 'desc'
      sorted_hearings
    end
  end
end
