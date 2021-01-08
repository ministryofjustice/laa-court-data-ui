# frozen_string_literal: true

class HearingDecorator < BaseDecorator
  def provider_list
    return t('generic.not_available') if providers.blank? || providers.empty?

    safe_join(provider_sentences, tag.br)
  end

  def defendant_name_list
    return t('generic.not_available') if defendant_names.blank? || defendant_names.empty?

    safe_join(defendant_names, tag.br)
  end

  def prosecution_advocate_name_list
    return t('generic.not_available') \
      if prosecution_advocate_names.blank? || prosecution_advocate_names.empty?

    safe_join(prosecution_advocate_names, tag.br)
  end

  def judge_name_list
    return t('generic.not_available') \
      if judge_names.blank? || judge_names.empty?

    safe_join(judge_names, tag.br)
  end

  private

  def decorated_providers
    decorate_all(providers)
  end

  def provider_sentences
    decorated_providers&.map(&:name_and_role) || []
  end
end
