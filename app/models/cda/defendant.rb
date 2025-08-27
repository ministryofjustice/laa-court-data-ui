# frozen_string_literal: true

module Cda
  class Defendant < BaseModel
    def self.find_from_id_and_urn(defendant_id, urn)
      find(:one,
           from: "/api/internal/v2/prosecution_cases/#{safe_path(urn)}/" \
                 "defendants/#{safe_path(defendant_id)}")
    end

    def name
      attributes['name'].presence || [first_name, middle_name, last_name].filter_map(&:presence).join(" ")
    end

    def full_name
      # NOTE: middle_name is not present inside defendant_details.person_details
      [defendant_details.person_details.first_name,
       defendant_details.person_details.last_name].filter_map(&:presence).join(" ")
    end
  end
end
