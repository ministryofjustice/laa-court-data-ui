# frozen_string_literal: true

module Cda
  class DefenceCounselDecorator < BaseDecorator
    def name_status_and_defendants
      return t('generic.not_available') if name_and_status_blank?

      return "#{formatted_name} (#{formatted_status})" if defendants.blank?

      defence_counsel_list = formatted_defendant_names.map do |defendant_name|
        "#{formatted_name} (#{formatted_status}) for #{defendant_name}"
      end
      safe_join(defence_counsel_list, tag.br)
    end

    private

    def name_and_status_blank?
      name.blank? && status.blank?
    end

    def name
      return nil unless first_name || middle_name || last_name

      [first_name, middle_name, last_name].filter_map { |n| n&.capitalize }.reject(&:empty?).join(' ')
    end

    def formatted_name
      name || t('generic.not_available')
    end

    def formatted_status
      status || t('generic.not_available').downcase
    end

    def formatted_defendant_names
      names = []
      defendants.map do |defendant|
        next(names << t('generic.not_available').downcase) if defendant.nil? || defendant.is_a?(String)

        names << defendant.name
      end

      names.compact
    end
  end
end
