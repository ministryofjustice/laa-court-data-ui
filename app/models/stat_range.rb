class StatRange
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Attributes

  attribute :from, :date
  attribute :to, :date

  validates :from, presence: true
  validates :to, presence: true
end
