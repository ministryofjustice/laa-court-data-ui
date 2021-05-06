# frozen_string_literal: true

module TableSorters
  class HearingsTypeSorter < HearingsSorter
    def sorted_hearings
      order_by_asc_or_desc(@hearings.sort_by(&:hearing_type))
    end
  end
end
