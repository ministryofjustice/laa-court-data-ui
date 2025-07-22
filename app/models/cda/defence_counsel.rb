module Cda
  class DefenceCounsel < BaseModel
    def attended_on?(date)
      attendance_dates.include?(date)
    end

    def name
      "#{title.capitalize} #{first_name} #{last_name} (#{status})"
    end

    def attendance_dates
      @attendance_dates ||= attendance_days.map(&:to_date)
    end
  end
end
