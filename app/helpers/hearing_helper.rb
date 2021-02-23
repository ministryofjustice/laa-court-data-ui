# frozen_string_literal: true

module HearingHelper
  def paginator(...)
    HearingPaginator.new(...)
  end

  def earliest_day_for(hearing)
    hearing&.hearing_days&.map(&:to_datetime)&.sort&.first
  end
end
