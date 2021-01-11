# frozen_string_literal: true

class ProviderDecorator < BaseDecorator
  def name_and_role
    return t('generic.not_available') if name_and_role_blank?

    "#{formatted_name} (#{formatted_role})"
  end

  private

  def name_and_role_blank?
    name.blank? && role.blank?
  end

  def formatted_name
    name || t('generic.not_available')
  end

  def formatted_role
    role || t('generic.not_available').downcase
  end
end
