# frozen_string_literal: true

class ProsecutionCaseDecorator < BaseDecorator
  def hearings
    @hearings ||= decorate_all(object.hearings)
  end

  # def hearings_by_datetime
  #   hearings.sort_by { |h| h.hearing_days.map(&:to_datetime) }
  # end

  # def hearings_with_day_by_datetime
  #   Enumerator.new do |enum|
  #     hearings_by_datetime.each do |hearing|
  #       hearing.hearing_days.map(&:to_datetime).sort.each do |day|
  #         hearing.day = day
  #         enum.yield(hearing)
  #       end
  #     end
  #   end
  # end

  def cracked?
    hearings.map { |h| h.cracked_ineffective_trial&.cracked? }.any?
  end
end
