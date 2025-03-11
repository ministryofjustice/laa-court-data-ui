# frozen_string_literal: true

module Faker
  class UnlinkReason
    class << self
      def description
        Faker::Base.fetch('unlink_reason.description')
      end
    end
  end
end
