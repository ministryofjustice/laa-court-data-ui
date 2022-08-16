# frozen_string_literal: true

module CdApi
  class OverallDefendantDecorator < BaseDecorator
    def name
      # TODO: Create a name service to build the name for reusability
      [first_name, middle_name, last_name].compact.reject(&:empty?).join(' ')
    end

    def linked?
      maat_reference&.present? && maat_reference.first != "Z"
    end
  end
end
