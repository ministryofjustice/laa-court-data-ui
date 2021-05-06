# frozen_string_literal: true

module TableSorters
  class HearingsProviderSorter < HearingsSorter
    def sorted_hearings
      order_by_asc_or_desc(@hearings.sort_by(&:provider_list))
    end
  end
end
