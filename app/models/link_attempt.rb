# frozen_string_literal: true

class LinkAttempt
  include ActiveModel::Model

  attr_accessor :maat_reference, :defendant_id, :username

  validates :username, presence: true
  validates :defendant_id, presence: true
  validates :maat_reference, format: { with: /\A[0-9]{7}\z/ }, allow_blank: true

  with_options on: :maat_ref_required do
    validates :maat_reference, presence: true
    validates :maat_reference, format: { with: /\A[0-9]{7}\z/ }, allow_blank: true
  end

  def to_link_attributes
    { defendant_id:, user_name: username }.tap do |attrs|
      attrs.merge!(maat_reference:) if maat_reference.present?
    end
  end
end
