# frozen_string_literal: true

class LinkAttempt
  include ActiveModel::Model
  attr_accessor :id, :defendant_id, :defendant_asn, :maat_reference, :no_maat_id

  validates :maat_reference,
            format: { with: /\A[0-9]{7}\z/, unless: :no_maat_id  }
end
