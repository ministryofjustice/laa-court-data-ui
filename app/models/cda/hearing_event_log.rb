# frozen_string_literal: true

module Cda
  class HearingEventLog < BaseModel
    def self.find_from_hearing_and_date(hearing_id, date)
      find(:one,
           from: "/api/internal/v2/hearings/#{make_safe_for_path(hearing_id)}/" \
                 "event_log/#{make_safe_for_path(date)}")
    end
  end
end
