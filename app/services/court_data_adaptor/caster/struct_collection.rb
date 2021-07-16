# frozen_string_literal: true

# see https://github.com/JsonApiClient/json_api_client#type-casting
#
module CourtDataAdaptor
  module Caster
    class StructCollection
      def self.cast(value, default = [])
        value ||= default
        value.map { |el| OpenStruct.new(el) }
      end
    end
  end
end
