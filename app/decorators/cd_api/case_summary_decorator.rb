# frozen_string_literal: true

module CdApi
  class CaseSummaryDecorator < BaseDecorator
    attr_accessor :prosecution_case_reference
    attr_writer :hearings_sort_column, :hearings_sort_direction

    def hearings
      @hearings ||= decorate_all(object.hearing_summaries, CdApi::HearingSummaryDecorator)
    end

    def defendants
      @defendants ||= decorate_all(object.overall_defendants, CdApi::OverallDefendantDecorator)
    end

    def sorted_hearing_summaries_with_day
      Enumerator.new do |enum|
        sorter.sorted_hearings.each do |hearing|
          sorter.sorted_hearing_days(hearing).each do |day|
            hearing.day = day
            enum.yield(hearing)
          end
        end
      end
    end

    def column_sort_icon
      hearings_sort_direction == 'asc' ? "\u25B2" : "\u25BC"
    end

    def column_title(column)
      Hash.new(t('search.result.hearing.hearing_day')).merge(
        type: t('search.result.hearing.hearing_type'),
        provider: t('search.result.hearing.providers')
      )[column.to_sym]
    end

    def hearings_sort_column
      @hearings_sort_column ||= 'date'
    end

    def hearings_sort_direction
      @hearings_sort_direction ||= 'asc'
    end

    private

    def sorter
      TableSorters::HearingsSorter.for(hearings, hearings_sort_column, hearings_sort_direction)
    end
  end
end
