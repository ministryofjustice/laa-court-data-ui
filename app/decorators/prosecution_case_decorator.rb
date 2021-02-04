# frozen_string_literal: true

class ProsecutionCaseDecorator < BaseDecorator
  def hearings
    @hearings ||= decorate_all(object.hearings)
  end

  def hearings_by_datetime
    hearings.sort_by { |h| h.hearing_days.map(&:to_datetime) }
  end

  def cracked?
    hearings.map { |h| h.cracked_ineffective_trial&.cracked? }.any?
  end
end
