# frozen_string_literal: true

module Cda
  class HearingEventLog < BaseModel
    def self.find_from_hearing_and_date(hearing_id, date)
      find(:one, from: "/api/internal/v2/hearings/#{hearing_id}/event_log/#{date}")
    end
  end
end
