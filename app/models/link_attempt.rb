# frozen_string_literal: true

class LinkAttempt
  include ActiveModel::Model
  attr_accessor :maat_reference, :defendant_id, :no_maat_id

  alias no_maat_id? no_maat_id

  validates :maat_reference,
            format: { with: /\A[0-9]{7}\z/, unless: :no_maat_id? }
end
