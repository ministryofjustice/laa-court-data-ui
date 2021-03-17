# frozen_string_literal: true

class ProsecutionCaseDecorator < BaseDecorator
  attr_accessor :sort_order

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

  private

  def sorter
    case sort_order
    when /^type/
      TableSorters::HearingsTypeSorter.new(hearings, sort_order)
    when /^provider/
      TableSorters::HearingsProviderSorter.new(hearings, sort_order)
    else
      TableSorters::HearingsSorter.new(hearings, sort_order)
    end
  end
end
