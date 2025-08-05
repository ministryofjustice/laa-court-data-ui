module Cda
  class HearingDay < BaseModel
    attr_accessor :hearing

    def day_string
      date.strftime('%d/%m/%Y')
    end

    def time_string
      sitting_day.to_time.strftime('%H:%M')
    end

    def date
      sitting_day.to_date
    end

    # By default ActiveResource compares IDs, I think, and these objects always
    # have a nil ID.
    def ==(other)
      sitting_day == other.sitting_day
    end
  end
end
