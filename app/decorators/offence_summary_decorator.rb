# frozen_string_literal: true

class OffenceSummaryDecorator < BaseDecorator
  def plea_sentence
    return t('generic.not_available') if pleas.blank?
    return pleas unless pleas.is_a?(Enumerable)

    safe_join(plea_sentences, tag.br)
  end

  private

  def plea_sentences
    sorted_pleas.map { |plea| return_plea(plea) }
  end

  def sorted_pleas
    pleas.sort_by { |plea| plea&.date || Date.new.iso8601 }
  end

  def return_plea(plea)
    plea_date = plea&.date&.to_date

    t('offence.plea.sentence',
      plea: plea&.value&.humanize || t('generic.not_available'),
      pleaded_at: plea_date&.strftime('%d/%m/%Y') || t('generic.not_available'))
  end
end
