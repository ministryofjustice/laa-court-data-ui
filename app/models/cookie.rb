# frozen_string_literal: true

class Cookie
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Attributes

  attribute :analytics

  validates :analytics, presence: true
  validates :analytics, inclusion: { in: %w[true false] }
end
