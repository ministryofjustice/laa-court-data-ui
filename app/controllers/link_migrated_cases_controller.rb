# frozen_string_literal: true

class LinkMigratedCasesController < ApplicationController
  authorize_resource class: false
  before_action :check_feature_flag

  SORTABLE_COLUMNS = %w[case_urn defendant_name xhibit_case_number court_name mode_of_trial].freeze
  CASES_PER_PAGE = 10
  TABS = { 'need_linking' => 'pending', 'manually_linked' => 'manually_linked',
           'auto_linked' => 'auto_linked' }.freeze

  def index
    @tab = tab_param

    if @tab == 'need_linking'
      @result = Cda::LinkMigratedCasesService.call(status: TABS[@tab],
                                                   sort_by: sort_col_param, sort_direction: sort_dir_param,
                                                   page: page_param, per_page: CASES_PER_PAGE)
      @cases = @result['results'] || []
      @pagy = Pagy.new(count: @result['total_results'].to_i, page: page_param, limit: CASES_PER_PAGE)
      @pending_count = @pagy.count
    else
      pending_result = Cda::LinkMigratedCasesService.call(status: TABS['need_linking'], per_page: 1)
      @pending_count = pending_result['total_results'].to_i
      @cases = []
      @pagy = Pagy.new(count: 0, page: 1, limit: CASES_PER_PAGE)
    end
  end

  private

  def tab_param
    TABS.key?(params[:tab]) ? params[:tab] : 'need_linking'
  end

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
