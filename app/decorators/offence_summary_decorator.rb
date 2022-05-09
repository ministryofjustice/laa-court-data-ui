# frozen_string_literal: true

class OffenceSummaryDecorator < BaseDecorator
  def plea_sentence
    return t('generic.not_available') if plea&.value.blank?
    return_plea plea
  end

  private

  def return_plea(plea)
    t('offence.plea.sentence',
      plea: plea&.value&.humanize || t('generic.not_available'),
      pleaded_at: plea&.date&.to_date&.strftime('%d/%m/%Y') || t('generic.not_available'))
  end
end
