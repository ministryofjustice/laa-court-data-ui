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

    def application_search_breadcrumb_name
      I18n.t('search.application_breadcrumb')
    end
    helper_method :application_search_breadcrumb_name

    def search_breadcrumb_path
      searches_path(search: current_search_params)
    end
    helper_method :search_breadcrumb_path

    def prosecution_case_name(reference)
      I18n.t('prosecution_case.breadcrumb', prosecution_case_reference: reference)
    end
    helper_method :prosecution_case_name
  end
end
