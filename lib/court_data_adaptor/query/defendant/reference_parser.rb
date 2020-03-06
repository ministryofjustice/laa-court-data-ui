# frozen_string_literal: true

module CourtDataAdaptor
  module Query
    module Defendant
      class ReferenceParser
        # rubocop:disable Layout/LineLength
        NINO_REGEXP = /^(?!BG)(?!GB)(?!NK)(?!KN)(?!TN)(?!NT)(?!ZZ)(?:[A-CEGHJ-PR-TW-Z][A-CEGHJ-NPR-TW-Z])[0-9]{6}[A-D]{1}$/.freeze
        # rubocop:enable Layout/LineLength

        def initialize(term)
          @original_value = term
          @value = @original_value.delete("\s\t\r\n\/\-").upcase
        end

        attr_reader :original_value, :value

        def national_insurance_number?
          value.match?(NINO_REGEXP)
        end
      end
    end
  end
end
