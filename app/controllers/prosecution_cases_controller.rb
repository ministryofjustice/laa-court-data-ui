# frozen_string_literal: true

class ProsecutionCasesController < ApplicationController
  before_action :load_and_authorize_search, :set_prosecution_case

  add_breadcrumb :search_filter_breadcrumb_name, :new_search_filter_path
  add_breadcrumb :search_breadcrumb_name, :search_breadcrumb_path

  def show
    add_breadcrumb prosecution_case_name(@prosecution_case.prosecution_case_reference),
                   prosecution_case_path(@prosecution_case.prosecution_case_reference)
  end

  private

  def load_and_authorize_search
    if version_2?
      authorize! :read, CdApi::CaseSummary
    else
      @search = Search.new(filter: 'case_reference', term: params[:id], version2: version_2?)
      authorize! :create, @search
    end
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
    @prosecution_case ||= if version_2?
                            helpers.decorate(search_results, CdApi::CaseSummaryDecorator)
                          else
                            helpers.decorate(search_results.first)
                          end
    update_prosecution_case
  end

  def update_prosecution_case
    @prosecution_case.prosecution_case_reference = urn if version_2?
    @prosecution_case.hearings_sort_column = params[:column]
    @prosecution_case.hearings_sort_direction = params[:direction]
  end

  def search_results
    @search_results ||= version_2? ? query_v2_hearing_summaries : @search.execute
  end

  def version_2?
    Feature.enabled?(:hearing_summaries)
  end

  def urn
    params[:id]
  end

  def query_v2_hearing_summaries
    logger.info 'V2_PROSECUTION_CASE'
    CdApi::CaseSummary.find(urn)
  end

  def redirect_to_search_path
    redirect_to searches_path(search: { filter: 'case_reference', term: urn })
    flash[:notice] = I18n.t('prosecution_case.show.failure')
  end
end
