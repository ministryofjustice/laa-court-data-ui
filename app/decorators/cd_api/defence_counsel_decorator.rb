# frozen_string_literal: true

module CdApi
  class DefenceCounselDecorator < BaseDecorator

    def name_status_and_defendants
      return t('generic.not_available') if name_and_status_blank?

      return "#{formatted_name} (#{formatted_status})" if defendants.empty?

      defence_counsel_list = formatted_multiples_defendant_names.map do |defendant_name|
        "#{formatted_name} (#{formatted_status}) for #{defendant_name}"
      end
      safe_join(defence_counsel_list, tag.br)
    end

    private

    def name_and_status_blank?
      name.blank? && status.blank?
    end

    def name
      # TODO: Create a name service to build the name for reusability
      # and confirm the must have portions of a name or validations needed
      return nil unless first_name || middle_name || last_name

      [first_name, middle_name, last_name].compact.reject(&:empty?).join(' ')
    end

    def formatted_name
      name || t('generic.not_available')
    end

    def formatted_status
      status || t('generic.not_available').downcase
    end

    def formatted_multiples_defendant_names
      names = []
      defendants.map do |defendant|
        names << format_defendant_name(defendant&.first_name, defendant&.middle_name, defendant&.last_name)
      end

      return [] if names.empty?

      names.compact
    end

    def format_defendant_name(first_name, middle_name, last_name)
      # TODO: Create a name service to build the name for reusability
      # and confirm the must have portions of a name or validations needed
      return nil unless first_name || middle_name || last_name

      [first_name, middle_name, last_name].compact.reject(&:empty?).join(' ')
    end
  end
end
