module Cda
  class DefendantSummary < BaseModel
    has_many :offence_summaries, class_name: 'Cda::OffenceSummary'

    def name
      [first_name, middle_name, last_name].filter_map(&:presence).join(" ")
    end
  end
end
