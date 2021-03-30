# frozen_string_literal: true

module TableSorters
  class HearingsSorter
    def initialize(hearings, sort_order)
      @hearings = hearings
      @sort_order = sort_order
    end

    def self.for(hearings, sort_order)
      case sort_order
      when /^type/
        TableSorters::HearingsTypeSorter.new(hearings, sort_order)
      when /^provider/
        TableSorters::HearingsProviderSorter.new(hearings, sort_order)
      else
        TableSorters::HearingsDateSorter.new(hearings, sort_order)
      end
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
