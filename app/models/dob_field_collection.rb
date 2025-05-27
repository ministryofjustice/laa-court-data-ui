# The goal of the class is to ensure that, if the user enters invalid values, like 35 January 2023,
# we preserve what the user entered so we can show it back to them with an appropriate error message.
# If we were to directly parse to a Date, invalid values would be rejected and at best we could
# represent the entire attribute as `nil`, losing the specifics of what was invalid.
class DobFieldCollection
  def initialize(params)
    return unless params

    @year = params["dob(1i)"]
    @month = params["dob(2i)"]
    @day = params["dob(3i)"]
  end

  attr_reader :day, :month, :year

  def blank?
    [@year, @month, @day].all?(&:blank?)
  end

  def valid?
    !to_date.nil? && (150.years.ago.to_date..Date.current).cover?(to_date)
  end

  def to_s
    to_date&.strftime('%F')
  end

  def to_date
    @to_date ||= Date.new(@year.to_i, @month.to_i, @day.to_i)
  rescue Date::Error
    nil
  end
end
