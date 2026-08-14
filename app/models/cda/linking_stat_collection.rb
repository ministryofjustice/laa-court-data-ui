module Cda
  class LinkingStatCollection < BaseModel
    def self.find_from_range(from, to)
      find(:one, from: "/api/internal/v2/stats/linking", params: { from:, to: })
    end
  end
end
