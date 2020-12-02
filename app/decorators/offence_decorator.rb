# frozen_string_literal: true

class OffenceDecorator < BaseDecorator
  def plea_list
    return t('generic.not_available') if pleas.blank?
    return pleas unless pleas.is_a?(Enumerable)

    safe_join(plea_sentences, tag.br)
  end

  private

  def plea_sentences
    sorted_pleas.map { |plea| plea_sentence(plea) }
  end

  def sorted_pleas
    pleas.sort_by { |plea| plea&.pleaded_at || Date.new.iso8601 }
  end

  def plea_sentence(plea)
    t('offence.plea.sentence',
      plea: plea.code&.humanize || t('generic.not_available'),
      pleaded_at: plea.pleaded_at&.to_date&.strftime('%d/%m/%Y') || t('generic.not_available'))
  end
end
