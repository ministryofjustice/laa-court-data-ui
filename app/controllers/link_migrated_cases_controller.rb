# frozen_string_literal: true

class LinkMigratedCasesController < ApplicationController
  authorize_resource class: false
  before_action :check_feature_flag

  SORTABLE_COLUMNS = %w[case_urn defendant_name xhibit_case_number court_name mode_of_trial].freeze
  CASES_PER_PAGE = 10

  def index
    @result = Cda::LinkMigratedCasesService.call(sort_by: sort_col_param,
                                                 sort_direction: sort_dir_param,
                                                 page: page_param,
                                                 per_page: CASES_PER_PAGE)
    @cases = @result['results'] || []
    @pagy = Pagy.new(count: @result['total_results'].to_i, page: page_param, limit: CASES_PER_PAGE)
  end

  private

  def sort_col_param
    SORTABLE_COLUMNS.include?(params[:sort_column]) ? params[:sort_column] : 'case_urn'
  end

  def sort_dir_param
    params[:sort_direction] == 'desc' ? 'desc' : 'asc'
  end

  def page_param
    [params[:page].to_i, 1].max
  end

  def check_feature_flag
    unless FeatureFlag.enabled?(:show_link_migrated_cases)
      redirect_to authenticated_user_root_path(current_user)
    end
  end
end
