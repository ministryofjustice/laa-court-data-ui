# frozen_string_literal: true

module CourtDataAdaptor
  module Caster
    class ModeOfTrialReasonCollection
      def self.cast(value, default = [])
        value ||= default
        value.map { |el| CourtDataAdaptor::Resource::ModeOfTrialReason.new(el) }
      end
    end
  end
end
