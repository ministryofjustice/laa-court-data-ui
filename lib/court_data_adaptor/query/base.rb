# frozen_string_literal: true

module CourtDataAdaptor
  module Query
    class Base
      include CourtDataAdaptor::Resource::Queryable

      attr_accessor :term

      def initialize(term)
        @term = term
      end

      def self.call(term)
        new(term).call
      end

      def call
        raise 'Implement in subclass, e.g. resource.where(attribute: term).all'
      end
    end
  end
end
