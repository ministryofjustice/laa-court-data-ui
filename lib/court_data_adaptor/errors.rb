# frozen_string_literal: true

module CourtDataAdaptor
  module Errors
    class Error < StandardError
      def initialize(msg, response)
        @response = response
        @status = response.status
        @errors = response.body
        @error_string = format_user_facing_string
        super(msg)
      end
      attr_reader :response, :status, :errors, :error_string

      private

      def format_user_facing_string
        user_facing_string = retrieve_user_facing_string
        user_facing_string ? "#{I18n.t('generic.defendant')} #{user_facing_string}" : I18n.t('error.it_helpdesk')
      end

      def retrieve_user_facing_string
        # Believe it or not, if CDA returns an unprocessable entity error, the response JSON will contain
        # a key called "error" whose value will be a string that includes a ruby hash literal, e.g.
        # `{"error"=>"Contract failed with: {:defendant_id=>[\"cannot be linked right now as we do not have all the required information, please try again later\"]}"}`
        mangled_user_facing_string = @errors&.dig("error")&.match(/\["(.*)"\]/) if @errors.is_a?(Hash)
        mangled_user_facing_string&.to_a&.last
      end
    end

    class BadRequest < Error; end

    class UnprocessableEntity < Error; end

    class InternalServerError < Error; end

    class ClientError < Error; end
  end
end
