# frozen_string_literal: true

module Cda
  class HearingDayDecorator < BaseDecorator
    def to_datetime
      sitting_day&.to_datetime
    end
  end
end
