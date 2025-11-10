class StatRange
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Attributes

  attribute :from, :string
  attribute :to, :string

  validates :from, :to, presence: true
  validate :valid_date_format

  DATE_FORMAT = '%d/%m/%Y'.freeze
  DATE_REGEX = %r{\A\d{1,2}/\d{2}/\d{4}\z}

  private

  def valid_date_format
    errors.add(:from, 'Start date must be in format dd/mm/yyyy') unless valid_date?(from)
    errors.add(:to, 'End date must be in format dd/mm/yyyy') unless valid_date?(to)

    return unless valid_date?(from) && valid_date?(to)
    from_date = Date.strptime(from, DATE_FORMAT)
    to_date = Date.strptime(to, DATE_FORMAT)
    return unless from_date > to_date
    errors.add(:from, 'End date must be after start date')
  end

  def valid_date?(value)
    return false unless value.match?(DATE_REGEX)
    Date.strptime(value, DATE_FORMAT)
    true
  rescue ArgumentError, TypeError
    false
  end
end
