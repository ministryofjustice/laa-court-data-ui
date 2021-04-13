# frozen_string_literal: true

module TableSorters
  class HearingsSorter
    def initialize(hearings, column, direction)
      @hearings = hearings
      @column = column
      @direction = direction
    end

    def self.for(hearings, column, direction)
      Hash.new(TableSorters::HearingsDateSorter.new(hearings, column, direction)).merge(
        type: TableSorters::HearingsTypeSorter.new(hearings, column, direction),
        provider: TableSorters::HearingsProviderSorter.new(hearings, column, direction)
      )[column&.to_sym]
    end

    def sorted_hearing_days(hearing)
      hearing.hearing_days.map(&:to_datetime).sort
    end

    protected

    def order_by_asc_or_desc(arr)
      return arr.reverse if @direction == 'desc'
      arr
    end
  end
end
