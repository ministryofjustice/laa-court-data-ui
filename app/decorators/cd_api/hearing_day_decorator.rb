# frozen_string_literal: true

module CdApi
  class HearingDayDecorator < BaseDecorator
    def to_datetime
      sitting_day&.to_datetime
    end
  end
end
