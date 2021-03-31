# frozen_string_literal: true

class ProsecutionCaseDecorator < BaseDecorator
  attr_accessor :column, :direction

  def hearings
    @hearings ||= decorate_all(object.hearings)
  end

  def sorted_hearings_with_day
    Enumerator.new do |enum|
      sorter.sorted_hearings.each do |hearing|
        sorter.sorted_hearing(hearing).each do |day|
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
    direction == 'asc' ? "\u25B2" : "\u25BC"
  end

  def column_title(column)
    case column
    when 'type'
      t('search.result.hearing.hearing_type')
    when 'provider'
      t('search.result.hearing.providers')
    else
      t('search.result.hearing.hearing_day')
    end
  end

  private

  def sorter
    TableSorters::HearingsSorter.for(hearings, column, direction)
  end
end
