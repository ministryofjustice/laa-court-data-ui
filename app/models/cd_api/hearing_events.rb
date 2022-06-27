# frozen_string_literal: true

module CdApi
  class HearingEvents < BaseModel
    def self.find(id, params) 
      id = id.to_s
      superclass.find(:one, params: params, from: "/v2/hearings/#{id}/hearing_events")
    end
  end
end
