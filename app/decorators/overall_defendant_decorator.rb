# frozen_string_literal: true

class OverallDefendantDecorator < BaseDecorator
  def name
    [first_name, middle_name, last_name].compact.join(' ')
  end

  def linked?
    maat_reference&.present?
  end
end
