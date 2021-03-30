# frozen_string_literal: true

module TableSorters
  class HearingsSorter
    def initialize(hearings, column, direction)
      @hearings = hearings
      @column = column
      @direction = direction
    end

    def self.for(hearings, column, direction)
      case column
      when 'type'
        TableSorters::HearingsTypeSorter.new(hearings, column, direction)
      when 'provider'
        TableSorters::HearingsProviderSorter.new(hearings, column, direction)
      else
        TableSorters::HearingsDateSorter.new(hearings, column, direction)
      end
    end

    def sorted_hearing(hearing)
      hearing.hearing_days.map(&:to_datetime).sort
    end

    private

    def order_by_asc_or_desc(arr)
      return arr.reverse if @direction == 'desc'
      arr
    end
  end
end
