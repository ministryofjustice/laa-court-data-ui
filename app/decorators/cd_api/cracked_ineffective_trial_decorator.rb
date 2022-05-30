# frozen_string_literal: true

module CdApi
  class CrackedIneffectiveTrialDecorator < BaseDecorator
    VACATED_CRACKED_TRIAL_CODES = %w[A L M N O Q].freeze

    def cracked?
      return unless type

      [
        type.casecmp('cracked').zero?,
        type.casecmp('vacated').zero? && code.in?(VACATED_CRACKED_TRIAL_CODES)
      ].any?
    end

    def description_sentence
      "#{type.humanize}: #{description}"
    end
  end
end
