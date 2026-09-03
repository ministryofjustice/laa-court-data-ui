# frozen_string_literal: true

module Breadcrumbs
  include AbstractController::Translation
  extend ActiveSupport::Concern

  included do
    def search_filter_breadcrumb_name
      t("search_filter.breadcrumb")
    end
    helper_method :search_filter_breadcrumb_name

    def search_breadcrumb_name
      t("search.breadcrumb")
    end
    helper_method :search_breadcrumb_name

    def search_breadcrumb_path
      searches_path(search: current_search_params)
    end
    helper_method :search_breadcrumb_path

    def prosecution_case_name(reference)
      t("prosecution_case.breadcrumb", prosecution_case_reference: reference)
    end
    helper_method :prosecution_case_name

    def link_migrated_cases_breadcrumb_home
      t("link_migrated_cases.breadcrumbs.home")
    end
    helper_method :link_migrated_cases_breadcrumb_home

    def link_migrated_cases_breadcrumb_title
      t("link_migrated_cases.breadcrumbs.title")
    end
    helper_method :link_migrated_cases_breadcrumb_title
  end
end
