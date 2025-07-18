module Cda
  class OffenceHistoryCollection < BaseModel
    has_many :offence_histories, class_name: 'Cda::OffenceHistory'

    def self.find_from_id_and_urn(defendant_id, urn)
      find(:one,
           from: "/api/internal/v2/prosecution_cases/#{safe_path(urn)}/" \
                 "defendants/#{safe_path(defendant_id)}/offence_history")
    end
  end
end
