# frozen_string_literal: true

class HearingDecorator < BaseDecorator
  def provider_list
    return t('generic.not_available') if providers.blank? || providers.empty?

    safe_join(provider_sentences, tag.br)
  end

  private

  def decorated_providers
    decorate_all(providers)
  end

  def provider_sentences
    decorated_providers&.map(&:name_and_role) || []
  end
end
