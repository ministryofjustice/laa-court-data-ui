# frozen_string_literal: true

module TableSorters
  class HearingsProviderSorter < HearingsSorter
    def sorted_hearings
      if FeatureFlag.enabled?(:hearing_summaries)
        order_by_asc_or_desc(@hearings.sort_by(&:defence_counsel_list))
      else
        order_by_asc_or_desc(@hearings.sort_by(&:provider_list))
      end
    end
  end
end
