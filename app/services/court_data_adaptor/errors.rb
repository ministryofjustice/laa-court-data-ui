# frozen_string_literal: true

module CourtDataAdaptor
  module Errors
    class Error < StandardError; end

    class BadRequest < Error
      def initialize(msg, response)
        @response = response
        @status = response.status
        @errors = response.body
        super(msg)
      end

      attr_reader :response, :status, :errors
    end

    class UnprocessableEntity < Error
      def initialize(msg, response)
        @response = response
        @status = response.status
        @errors = response.body
        super(msg)
      end

      attr_reader :response, :status, :errors
    end
  end
end
