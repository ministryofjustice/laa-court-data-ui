# frozen_string_literal: true

module CourtDataAdaptor
  module Errors
    class Error < StandardError
      def initialize(msg, response)
        @response = response
        @status = response.status
        @errors = response.body
        @error_string = build_error_string
        super(msg)
      end
      attr_reader :response, :status, :errors, :error_string

      private

      def build_error_string
        build_from_error_code || parse_from_body || I18n.t('error.it_helpdesk')
      end

      def build_from_error_code
        ErrorCodeParser.call(response)
      end

      def parse_from_body
        # Believe it or not, if CDA returns an unprocessable entity error, the response JSON will contain
        # a key called "error" whose value will be a string that includes a ruby hash literal, e.g.
        # `{"error"=>"Contract failed with: {:defendant_id=>[\"cannot be linked right now as we do not have all the required information, please try again later\"]}"}`
        regex_match = @errors&.dig("error")&.match(/:([^\s]*?)=>\["(.*?)"\]/) if @errors.is_a?(Hash)

        return unless regex_match

        "#{regex_match[1].humanize} #{regex_match[2]}"
      end
    end

    class ErrorCodeParser
      def self.call(cda_response)
        return unless cda_response

        body = cda_response.body
        error_response = body.is_a?(String) ? JSON.parse(body) : body
        return unless error_response['error_codes']

        error_response['error_codes']
          .filter_map { |code| build_message(code) }
          .join(" ")
          .presence
      rescue StandardError => e
        Rails.logger.error "CourtDataAdaptor::Errors::ErrorCodeParser error: #{e.message}"
        nil
      end

      def self.build_message(code)
        return unless code && I18n.t('cda_errors').key?(code.to_sym)

        I18n.t("cda_errors.#{code}")
      end
    end

    class BadRequest < Error; end

    class UnprocessableEntity < Error; end

    class InternalServerError < Error; end

    class ClientError < Error; end
  end
end
