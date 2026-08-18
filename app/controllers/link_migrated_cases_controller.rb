# frozen_string_literal: true

class LinkMigratedCasesController < ApplicationController
  authorize_resource class: false, except: %i[show_link link]
  before_action :load_and_authorize_access,
                :load_defendant,
                :load_prosecution_case,
                :load_offence_histories, only: %i[show_link link offences]
  before_action :check_feature_flag, :set_breadcrumbs

  SORTABLE_COLUMNS = %w[auto_linked_at
                        case_urn
                        case_urn_new_tab
                        defendant_name
                        xhibit_case_number
                        court_name
                        mode_of_trial
                        reason_for_man_linking
                        maat_id
                        defendant_date_of_birth
                        linked_at
                        linked_by].freeze
  CASES_PER_PAGE = 10
  TABS = %w[action_required pending manually_linked auto_linked].freeze
  COLUMNS = {
    "action_required" => %w[case_urn
                            defendant_name
                            xhibit_case_number
                            court_name
                            mode_of_trial
                            reason_for_man_linking
                            action],
    "pending" => %w[case_urn defendant_name xhibit_case_number court_name mode_of_trial],
    "manually_linked" => %w[case_urn_new_tab
                            maat_id
                            defendant_name
                            defendant_date_of_birth
                            linked_at
                            linked_by],
    "auto_linked" => %w[case_urn_new_tab maat_id defendant_name defendant_date_of_birth auto_linked_at],
  }.freeze

  def index
    @tab = current_tab_param

    @result = Cda::LinkMigratedCasesService.call(status: @tab,
                                                 sort_by: sort_col_param, sort_direction: sort_dir_param,
                                                 page: page_param, per_page: CASES_PER_PAGE)
    @cases = @result["results"] || []
    @pagy = Pagy.new(count: @result["total_results"].to_i, page: page_param, limit: CASES_PER_PAGE)
    @cases_count = fetch_counts
    @columns = COLUMNS[@tab]
  end

  def show_link
    @form_model = new_link_attempt
  end

  def link
    authorize! :create, :link_maat_reference, message: I18n.t("unauthorized.default")

    @form_model = new_link_attempt
    validate_link_attempt!

    Cda::ProsecutionCaseLaaReference.create!(@form_model.to_link_attributes)

    redirect_to link_link_migrated_case_path(@migrated_case.id),
                flash: { success_moj_banner: I18n.t("laa_reference.link.success") }
  rescue ActiveResource::ConnectionError => e
    handle_link_failure(e.message, e)
    render :show_link
  rescue ActiveModel::ValidationError
    render :show_link
  end

  def offences
    authorize! :create, :link_maat_reference, message: I18n.t("unauthorized.default")

    @offence_ids = params[:offence_ids]&.split(",")
    render :offences, layout: false
  end

private

  def fetch_counts
    TABS.index_with do |status|
      Cda::LinkMigratedCasesService.call(status: status, per_page: 1)["total_results"].to_i
    end
  end

  def current_tab_param
    TABS.include?(params[:tab]) ? params[:tab] : "pending"
  end

  def sort_col_param
    col = SORTABLE_COLUMNS.include?(params[:sort_column]) ? params[:sort_column] : "case_urn"
    case col
    when "reason_for_man_linking" then "process_errors"
    when "auto_linked_at" then "linked_at"
    when "case_urn_new_tab" then "case_urn"
    else col
    end
  end

  def sort_dir_param
    params[:sort_direction] == "desc" ? "desc" : "asc"
  end

  def page_param
    [params[:page].to_i, 1].max
  end

  def check_feature_flag
    unless FeatureFlag.enabled?(:show_link_migrated_cases)
      redirect_to authenticated_user_root_path(current_user)
    end
  end

  def new_link_attempt
    LinkAttempt.new(
      defendant_id: @defendant.id,
      username: current_user.username,
      maat_reference: params.dig(:link_attempt, :maat_reference),
    )
  end

  def validate_link_attempt!
    if params[:maat_ref_required] == "true"
      @form_model.validate!(:maat_ref_required)
    else
      @form_model.maat_reference = nil
      @form_model.validate!
    end
  end

  def load_and_authorize_access
    @migrated_case = Cda::LinkMigratedCase.find_from_id(params[:id])
    authorize! :show, @migrated_case
  end

  def load_defendant
    @defendant = Cda::Defendant.find_from_id_and_urn(@migrated_case.defendant_id, @migrated_case.case_urn)
  end

  def load_prosecution_case
    @prosecution_case_search = Cda::CaseSummaryService.new(@migrated_case.case_urn)
    @prosecution_case = helpers.decorate(@prosecution_case_search.call, Cda::CaseSummaryDecorator)
  end

  def load_offence_histories
    @offence_history_collection = Cda::OffenceHistoryCollection.find_from_id_and_urn(@migrated_case.defendant_id,
                                                                                     @migrated_case.case_urn)
  end

  def set_breadcrumbs
    add_breadcrumb :link_migrated_cases_breadcrumb_home, :new_search_filter_path
    add_breadcrumb :link_migrated_cases_breadcrumb_title, link_migrated_cases_path(tab: :action_required)
    add_breadcrumb "Link" if action_name.in?(%w[show_link link])
  end

  def handle_link_failure(message, exception = nil)
    logger.warn "LINK MIGRATED CASE FAILURE (params: #{@form_model.as_json}): #{message}"
    @form_model.errors.add(:maat_reference,
                           cda_error_string(exception) || t("cda_errors.internal_server_error"))
  end
end
