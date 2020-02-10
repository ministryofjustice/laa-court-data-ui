# frozen_string_literal: true

class SearchFilter
  include ActiveModel::Model

  validates :id, presence: { message: 'Choose a filter' }

  attr_accessor :id, :name, :description
end
