# frozen_string_literal: true

module Breadcrumbs
  extend ActiveSupport::Concern

  included do
    def search_filter_breadcrumb_name
      I18n.t('search_filter.breadcrumb')
    end
    helper_method :search_filter_breadcrumb_name

    def search_breadcrumb_name
      I18n.t('search.breadcrumb')
    end
    helper_method :search_breadcrumb_name

    def search_breadcrumb_path
      new_search_path(search: { filter: current_search_filter })
    end
    helper_method :search_breadcrumb_path
  end
end
