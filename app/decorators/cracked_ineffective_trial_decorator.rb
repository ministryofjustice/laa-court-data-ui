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

  def cracked_on_sentence(hearing, prosecution_case)
    t('cracked_ineffective_trial.cracked_on_sentence_html',
      type: type&.humanize,
      cracked_at_link: cracked_at_link(hearing, prosecution_case))
  end

  def description_sentence
    "#{type.humanize}: #{description}"
  end

  private

  def cracked_at_link(hearing, prosecution_case)
    heard_at = hearing.hearing_days.first.to_date.strftime('%d/%m/%Y')
    view.link_to(heard_at,
                 view.hearing_path(id: hearing.id,
                                   urn: prosecution_case.prosecution_case_reference,
                                   hearing_day: heard_at),
                 class: 'govuk-link')
  end
end
