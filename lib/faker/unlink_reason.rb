# frozen_string_literal: true

module Faker
  class UnlinkReason < Base
    class << self
      def description
        fetch('unlink_reason.description')
      end
    end
  end
end
