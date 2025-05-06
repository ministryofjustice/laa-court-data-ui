# frozen_string_literal: true

module CourtDataAdaptor
  module Errors
    class Error < StandardError
      def initialize(msg, response)
        @response = response
        @status = response.status
        @errors = response.body
        super(msg)
      end
      attr_reader :response, :status, :errors
    end

    class BadRequest < Error; end

    class UnprocessableEntity < Error; end

    class InternalServerError < Error; end

    class ClientError < Error; end
  end
end
