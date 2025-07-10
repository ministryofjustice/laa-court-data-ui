# frozen_string_literal: true

class CrackedIneffectiveTrialDecorator < BaseDecorator
  VACATED_CRACKED_TRIAL_CODES = %w[A L M N O Q].freeze

  def cracked?
    return false unless type

    [
      type.casecmp('cracked').zero?,
      type.casecmp('vacated').zero? && code.in?(VACATED_CRACKED_TRIAL_CODES)
    ].any?
  end

  def cracked_on_sentence(hearing)
    t('cracked_ineffective_trial.cracked_on_sentence',
      type: type&.humanize,
      cracked_at: cracked_at(hearing))
  end

  def description_sentence
    "#{type.humanize}: #{description}"
  end

  private

  def cracked_at(hearing)
    hearing.hearing_days.first.to_date.to_fs(:day_month_year)
  end
end
