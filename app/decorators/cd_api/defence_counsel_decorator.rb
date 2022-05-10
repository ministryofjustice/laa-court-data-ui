# frozen_string_literal: true

module CdApi
  class DefenceCounselDecorator < BaseDecorator
    def name_and_status
      return t('generic.not_available') if name_and_status_blank?

      "#{formatted_name} (#{formatted_status})"
    end

    private

    def name_and_status_blank?
      name.blank? && status.blank?
    end

    def name
      # TODO: Confirm the must have portions of a name
      return nil unless first_name || middle_name || last_name

      [first_name, middle_name, last_name].compact.reject(&:empty?).join(' ')
    end

    def formatted_name
      name || t('generic.not_available')
    end

    def formatted_status
      status || t('generic.not_available').downcase
    end
  end
end
