# frozen_string_literal: true

class OffenceDecorator < BaseDecorator
  # TODO: mot reason text mappings for 'Elected' and 'Directed'
  MODE_OF_TRIAL_REASON_MAPPINGS = {
    1 => nil,
    2 => nil,
    6 => nil
  }.freeze

  def plea_list
    return t('generic.not_available') if pleas.blank?
    return pleas unless pleas.is_a?(Enumerable)

    safe_join(plea_sentences, tag.br)
  end

  def mode_of_trial_reason_list
    return t('generic.not_available') if mode_of_trial_reasons.blank?
    return mode_of_trial_reasons unless mode_of_trial_reasons.is_a?(Enumerable)

    safe_join(mode_of_trial_reason_descriptions.compact, tag.br)
  end

  private

  def plea_sentences
    sorted_pleas.map { |plea| plea_sentence(plea.to_h) }
  end

  def sorted_pleas
    pleas.sort_by { |plea| plea.to_h[:pleaded_at] || Date.new.iso8601 }
  end

  def plea_sentence(plea)
    t('offence.plea.sentence',
      plea: plea[:code]&.humanize || t('generic.not_available'),
      pleaded_at: plea[:pleaded_at]&.to_date&.strftime('%d/%m/%Y') || t('generic.not_available'))
  end

  def mode_of_trial_reason_descriptions
    mode_of_trial_reasons.map { |reason| mode_of_trial_reason_description(reason.to_h) }
  end

  def mode_of_trial_reason_description(reason)
    description = reason[:description] || t('generic.not_available')
    MODE_OF_TRIAL_REASON_MAPPINGS.fetch(reason[:code]&.to_i, description)
  end
end
