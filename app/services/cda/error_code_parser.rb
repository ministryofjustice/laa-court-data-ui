# frozen_string_literal: true

module Cda
  class ErrorCodeParser
    def self.call(cda_response, context = nil)
      return unless cda_response

      body = cda_response.body
      error_response = body.is_a?(String) ? JSON.parse(body) : body
      return unless error_response['error_codes']

      error_response['error_codes']
        .filter_map { |code| build_message(code, context) }
        .join(" ")
        .presence
    rescue StandardError => e
      Rails.logger.error "Cda::ErrorCodeParser error: #{e.message}"
      nil
    end

    def self.build_message(code, context)
      if context && I18n.t("cda_errors.context.#{context}").key?(code.to_sym)
        return I18n.t("cda_errors.context.#{context}.#{code}")
      end

      return unless code && I18n.t('cda_errors').key?(code.to_sym)

      I18n.t("cda_errors.#{code}")
    end
  end
end
