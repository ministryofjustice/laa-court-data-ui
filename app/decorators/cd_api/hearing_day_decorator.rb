# frozen_string_literal: true

module CdApi
  class HearingDayDecorator < BaseDecorator
    def to_datetime
      Rails.logger.debug { ">>> HearingDayDecorator: #{object.inspect}" }
      Rails.logger.debug { ">>> class: #{object.class}" }
      sitting_day&.to_datetime
    end
  end
end
