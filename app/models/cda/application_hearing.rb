module Cda
  class ApplicationHearing < BaseModel
    has_many :hearing_days, class_name: 'Cda::HearingDay'
    has_many :defence_counsels, class_name: 'Cda::DefenceCounsel'

    def hearing_days
      @hearing_days ||= super.map do |day|
        day.tap { it.hearing = self }
      end
    end

    def defence_counsels_on(date)
      defence_counsels.select { _1.attended_on?(date) }
    end
  end
end
