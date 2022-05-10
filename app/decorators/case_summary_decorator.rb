# frozen_string_literal: true

class CaseSummaryDecorator < BaseDecorator
  attr_writer :hearings_sort_column, :hearings_sort_direction, :prosecution_case_reference

  def hearings
    @hearings ||= decorate_all(object.hearing_summaries)
  end

  def defendants
    @defendants ||= decorate_all(object.overall_defendants)
  end

  def sorted_hearings_v2_with_day
    Enumerator.new do |enum|
      sorter.sorted_hearings.each do |hearing|
        sorter.sorted_hearing_days(hearing).each do |day|
          hearing.day = day
          enum.yield(hearing)
        end
      end
    end
  end

  def cracked?
    hearings.map { |h| h.cracked_ineffective_trial&.cracked? }.any?
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

  attr_reader :prosecution_case_reference if Feature.enabled?(:hearing_summaries)

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
