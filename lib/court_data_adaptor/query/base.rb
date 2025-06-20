# frozen_string_literal: true

module CourtDataAdaptor
  module Query
    class Base
      include CourtDataAdaptor::ActsAsResource

      attr_accessor :term, :dob

      def initialize(term, options = {})
        @term = term
        @dob = options[:dob]
      end

      def self.call(term, options = {})
        new(term, options).call
      end

      def call
        resource.with_headers("X-Request-ID": Current.request_id) do
          refresh_token_if_required!
          make_request
        end
      end

      def make_request
        raise 'Implement in subclass, e.g. resource.where(attribute: term).all'
      end
    end
  end
end
