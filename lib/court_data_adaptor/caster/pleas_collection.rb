# frozen_string_literal: true

module CourtDataAdaptor
  module Caster
    class PleasCollection
      def self.cast(value, default = [])
        value ||= default
        value.map { |el| CourtDataAdaptor::Resource::Plea.new(el) }
      end
    end
  end
end
