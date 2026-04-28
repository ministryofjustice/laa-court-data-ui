# frozen_string_literal: true

class LinkMigratedCasesController < ApplicationController
  authorize_resource class: false
  before_action :check_feature_flag

  SORTABLE_COLUMNS = %w[case_urn defendant_name xhibit_case_number court_name mode_of_trial].freeze
  CASES_PER_PAGE = 10
  TABS = %w[need_linking pending manually_linked auto_linked].freeze
  COLUMNS = {
    'need_linking'    => %w[case_urn defendant_name xhibit_case_number court_name mode_of_trial reason_for_man_linking maat_id],
    'pending'         => %w[case_urn defendant_name xhibit_case_number court_name mode_of_trial],
    'manually_linked' => %w[case_urn defendant_name xhibit_case_number court_name mode_of_trial reason_for_man_linking maat_id],
    'auto_linked'     => %w[case_urn defendant_name xhibit_case_number court_name mode_of_trial maat_id]
  }.freeze

  def index
    @tab = current_tab_param

    @result = Cda::LinkMigratedCasesService.call(status: @tab,
                                                 sort_by: sort_col_param, sort_direction: sort_dir_param,
                                                 page: page_param, per_page: CASES_PER_PAGE)
    @cases = @result['results'] || []
    @pagy = Pagy.new(count: @result['total_results'].to_i, page: page_param, limit: CASES_PER_PAGE)
    @cases_count = fetch_counts
    @columns = COLUMNS[@tab]
  end

  private

  def fetch_counts
    TABS.index_with do |status|
      Cda::LinkMigratedCasesService.call(status: status, per_page: 1)['total_results'].to_i
    end
  end

  def current_tab_param
    TABS.include?(params[:tab]) ? params[:tab] : 'pending'
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
