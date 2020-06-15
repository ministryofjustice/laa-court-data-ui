# frozen_string_literal: true

class Feedback
  include ActiveModel::Model
  include ActiveModel::Validations

  RATINGS = {
    5 => 'Very satisfied',
    4 => 'Satisfied',
    3 => 'Neither satisfied nor dissatisfied',
    2 => 'Dissatisfied',
    1 => 'Very dissatisfied'
  }.freeze

  attr_accessor :comment, :rating, :email
  validates :rating, inclusion: { in: RATINGS.keys.map(&:to_s), message: :invalid }
end
