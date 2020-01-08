class SearchFilter
  include ActiveModel::Model

  validates :id, presence: true

  attr_accessor :id, :name, :description
end