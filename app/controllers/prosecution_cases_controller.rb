# frozen_string_literal: true

class ProsecutionCasesController < ApplicationController
  before_action :load_and_authorize_search, :set_prosecution_case

  add_breadcrumb :search_filter_breadcrumb_name, :new_search_filter_path
  add_breadcrumb :search_breadcrumb_name, :search_breadcrumb_path

  def show
    add_breadcrumb prosecution_case_name(@prosecution_case.prosecution_case_reference),
                   prosecution_case_path(@prosecution_case.prosecution_case_reference)

    render :show, locals: { prosecution_case: @prosecution_case }
  end

  private

  def load_and_authorize_search
    authorize! :read, Cda::ProsecutionCase
  end

  def set_prosecution_case
    build_prosecution_case
  rescue ActiveResource::BadRequest
    logger.info 'CLIENT_ERROR_OCCURRED'
    redirect_to_search_path
  rescue ActiveResource::ServerError, ActiveResource::ClientError => e
    logger.error 'SERVER_ERROR_OCCURRED'
    Sentry.capture_exception(e)
    redirect_to_search_path
  end

  def build_prosecution_case
    @prosecution_case ||= helpers.decorate(search_results, Cda::CaseSummaryDecorator)
    update_prosecution_case
  end

  def update_prosecution_case
    @prosecution_case.hearings_sort_column = params[:column]
    @prosecution_case.hearings_sort_direction = params[:direction]
  end

  def search_results
    @search_results ||= CourtDataAdaptor::CaseSummaryService.call(urn)
  end

  def urn
    params[:id]
  end

  def redirect_to_search_path
    redirect_to searches_path(search: { filter: 'case_reference', term: urn })
    flash[:notice] = I18n.t('prosecution_case.show.failure')
  end
end
