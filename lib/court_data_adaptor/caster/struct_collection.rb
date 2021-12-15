# frozen_string_literal: true

# see https://github.com/JsonApiClient/json_api_client#type-casting
#
module CourtDataAdaptor
  module Caster
    class StructCollection
      def self.cast(value, default = [])
        value ||= default
        value.map { |el| Struct.new(*el.keys.map(&:to_sym)).new(*el.values) }
      end
    end
  end
end
