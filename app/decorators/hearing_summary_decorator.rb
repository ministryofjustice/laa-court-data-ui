# frozen_string_literal: true

class HearingSummaryDecorator < BaseDecorator
  attr_accessor :day

  def provider_list
    return t('generic.not_available') if defence_counsels.blank?

    safe_join(provider_sentences, tag.br)
  end

  def hearing_days
    @hearing_days ||= decorate_all(object.hearing_days)
  end

  def defendant_name_list
    return t('generic.not_available') if defendant_names.blank?

    safe_join(defendant_names, tag.br)
  end

  def prosecution_advocate_name_list
    return t('generic.not_available') if prosecution_advocate_names.blank?

    safe_join(prosecution_advocate_names, tag.br)
  end

  def judge_name_list
    return t('generic.not_available') if judge_names.blank?

    safe_join(judge_names, tag.br)
  end

  def cracked_ineffective_trial
    @cracked_ineffective_trial ||= decorate(object&.cracked_ineffective_trial)
  end

  def hearing_events_for_day(hearing_day)
    hearing_events.select do |event|
      event.occurred_at.to_date == hearing_day.to_date
    end.sort_by(&:occurred_at)
  end

  private

  def decorated_defence_counsels
    decorate_all(defence_counsel)
  end

  def provider_sentences
    decorated_defence_counsels&.map(&:name_and_role) || []
  end
end
