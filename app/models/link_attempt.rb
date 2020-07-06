# frozen_string_literal: true

class LinkAttempt
  include ActiveModel::Model
  attr_accessor :id, :maat_reference, :no_maat_id

  validates :maat_reference,
            presence: { unless: :no_maat_id },
            format: { with: /\A[2-9][0-9]{6}\z/ }
end
