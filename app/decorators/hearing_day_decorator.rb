# frozen_string_literal: true

class HearingDayDecorator < BaseDecorator
  def to_datetime
    sitting_day&.to_datetime
  end
end
