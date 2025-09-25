module Cda
  class LinkingStatCollection < BaseModel
    def self.find_from_range(from, to)
      find(:one, from: "/api/internal/v2/stats/linking", params: { from:, to: })
    end

    def unlink_reason_types
      current_range.unlink_reason_codes.as_json.transform_keys { UnlinkReason.find_by(code: it).description }
    end
  end
end
