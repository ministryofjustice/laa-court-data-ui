# frozen_string_literal: true

class ProsecutionCasesController < ApplicationController
  before_action :load_and_authorize_search, :set_prosecution_case

  add_breadcrumb :search_filter_breadcrumb_name, :new_search_filter_path
  add_breadcrumb :search_breadcrumb_name, :search_breadcrumb_path
  before_action :add_final_breadcrumb

  def show
    render :show, locals: { prosecution_case: @prosecution_case }
  end

  def related_court_applications
    all_applications = Cda::CourtApplication.from_urn(@prosecution_case.prosecution_case_reference)
    pagy, court_applications = pagy_array(all_applications)
    render :related_court_applications,
           locals: { prosecution_case: @prosecution_case, court_applications:, pagy: }
  end

  private

  def load_and_authorize_search
    authorize! :read, Cda::ProsecutionCase
  end

  def set_prosecution_case
    build_prosecution_case
  rescue ActiveResource::ConnectionError => e
    logger.error 'SERVER_ERROR_OCCURRED'
    Sentry.capture_exception(e)
    redirect_to_search_path(e)
  end

  def build_prosecution_case
    raise(ActiveResource::BadRequest, "URN '#{urn}' not found") unless search_results
    @prosecution_case ||= helpers.decorate(search_results, Cda::CaseSummaryDecorator)
    update_prosecution_case
  end

  def update_prosecution_case
    @prosecution_case.hearings_sort_column = params[:column]
    @prosecution_case.hearings_sort_direction = params[:direction]
  end

  def search_results
    @search_results ||= Cda::CaseSummaryService.call(urn)
  end

  def urn
    params[:id]
  end

  def redirect_to_search_path(exception)
    redirect_to searches_path(search: { filter: 'case_reference', term: urn })
    flash[:notice] = cda_error_string(exception) || I18n.t('prosecution_case.show.failure')
  end

  def add_final_breadcrumb
    add_breadcrumb prosecution_case_name(@prosecution_case.prosecution_case_reference),
                   prosecution_case_path(@prosecution_case.prosecution_case_reference)
  end
end
