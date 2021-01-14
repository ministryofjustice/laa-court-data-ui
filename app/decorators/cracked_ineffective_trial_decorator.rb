# frozen_string_literal: true

class CrackedIneffectiveTrialDecorator < BaseDecorator
  VACATED_CRACKED_TRIAL_CODES = %w[A L M N O Q].freeze

  def cracked?
    return unless type

    [
      type.casecmp('cracked').zero?,
      type.casecmp('vacated').zero? && code.in?(VACATED_CRACKED_TRIAL_CODES)
    ].any?
  end

  def type_sentence(cracked_at_link)
    t('cracked_ineffective_trial.type_sentence_html', type: type&.humanize, cracked_at_link: cracked_at_link)
  end

  def description_sentence
    "#{type.humanize}: #{description}"
  end
end
