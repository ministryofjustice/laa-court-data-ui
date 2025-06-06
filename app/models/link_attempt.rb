# frozen_string_literal: true

class LinkAttempt
  include ActiveModel::Model
  attr_accessor :maat_reference, :defendant_id, :no_maat_id, :username

  alias no_maat_id? no_maat_id

  validates :username, presence: true
  validates :defendant_id, presence: true
  validates :maat_reference,
            format: { with: /\A[0-9]{7}\z/, unless: :no_maat_id? }

  def to_link_attributes
    { defendant_id:, user_name: username }.tap do |attrs|
      attrs.merge!(maat_reference:) unless no_maat_id?
    end
  end

  def validate!
    raise ActiveModel::ValidationError, self unless valid?
  end
end
