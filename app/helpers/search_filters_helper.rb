# frozen_string_literal: true

module SearchFiltersHelper
  def search_filter_options
    return Search.filters if FeatureFlag.enabled?(:search_by_xhibit_ref_flag)

    Search.filters.reject { it.id == :xhibit_case_number }
  end
end
