# frozen_string_literal: true

class ProsecutionCaseDecorator < BaseDecorator
  def hearings_summaries_by_datetime
    object.hearing_summaries.sort_by { |h| h.hearing_days.map(&:to_datetime) }
  end

  def hearings_summaries_with_day_by_datetime
    Enumerator.new do |enum|
      hearings_summaries_by_datetime.each do |hearing_summary|
        hearing_summary.hearing_days.map(&:to_datetime).sort.each do |day|
          hearing_summary.day = day
          enum.yield(hearing_summary)
        end
      end
    end
  end

  def cracked?
    hearings.map { |h| h.cracked_ineffective_trial&.cracked? }.any?
  end
end
