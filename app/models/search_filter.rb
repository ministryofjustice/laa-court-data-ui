# frozen_string_literal: true

class SearchFilter
  include ActiveModel::Model

  attr_accessor :id, :name, :description

  validates :id, presence: true
end
