# frozen_string_literal: true

require_dependency 'court_data_adaptor'

class HearingsController < ApplicationController
  before_action :load_and_authorize_search,
                :set_hearing,
                :set_hearing_day,
                :set_hearing_events

  add_breadcrumb :search_filter_breadcrumb_name, :new_search_filter_path
  add_breadcrumb :search_breadcrumb_name, :search_breadcrumb_path
  add_breadcrumb (proc { |v| v.prosecution_case_name(v.controller.prosecution_case_reference) }),
                 (proc { |v| v.prosecution_case_path(v.controller.prosecution_case_reference) })

  def show
    add_breadcrumb "#{t('generic.hearing_day')} #{hearing_day&.strftime('%d/%m/%Y')}", ''

    return if @hearing
    redirect_to_prosecution_case I18n.t('hearings.show.flash.notice.no_hearing_details')
  end

  def redirect_to_prosecution_case(message)
    redirect_back(fallback_location: prosecution_case_path(prosecution_case_reference),
                  allow_other_host: false,
                  notice: message)
  end

  def prosecution_case_reference
    @prosecution_case_reference ||= params[:urn]
  end

  private

  def load_and_authorize_search
    @prosecution_case_search = if Feature.enabled?(:hearing)
                                 CdApi::CaseSummaryService.new(urn: prosecution_case_reference)
                               else
                                 Search.new(filter: 'case_reference', term: prosecution_case_reference)
                               end
    authorize! :create, @prosecution_case_search
  end

  def set_hearing
    if Feature.enabled?(:hearing)
      hearing_v2
    else
      hearing
    end
  end

  def set_hearing_day
    hearing_day
  end

  def set_hearing_events
    hearing_events if Feature.enabled?(:hearing)
  end

  def hearing
    logger.info 'USING_V1_ENDPOINT'
    @hearing ||= helpers.decorate(prosecution_case.hearings.find { |hearing| hearing.id == params[:id] })
  end

  def hearing_v2
    logger.info 'USING_V2_ENDPOINT_HEARING'
    begin
      @hearing ||= CdApi::Hearing.find(params[:id], params: {
                                         date: paginator.current_item.hearing_date.strftime('%F')
                                       })
    rescue ActiveResource::ResourceNotFound
      redirect_to_prosecution_case I18n.t('hearings.show.flash.notice.no_hearing_details')
    rescue ActiveResource::ServerError, ActiveResource::ClientError => e
      logger.error 'SERVER_ERROR_OCCURRED'
      Sentry.capture_exception(e)
      redirect_to_prosecution_case I18n.t('hearings.show.flash.notice.server_error')
    end
  end

  def hearing_day
    @hearing_day ||= paginator.current_item.hearing_date || helpers.earliest_day_for(@hearing)
  end

  def paginator
    @paginator ||= helpers.paginator(prosecution_case, column:,
                                                       direction:, page:)
  end

  def prosecution_case
    @prosecution_case ||= if Feature.enabled?(:hearing)
                            logger.info 'USING_V2_ENDPOINT_HEARING_SUMMARIES'
                            helpers.decorate(@prosecution_case_search.call, CdApi::CaseSummaryDecorator)
                          else
                            logger.info 'USING_V1_ENDPOINT_PROSECUTION_CASE'
                            helpers.decorate(@prosecution_case_search.execute.first)
                          end
  end

  def hearing_events
    logger.info 'USING_V2_ENDPOINT_HEARING_EVENTS'
    @hearing_events ||= CdApi::HearingEvents.find(params[:id],
                                                  params: {
                                                    date: paginator.current_item.hearing_date.strftime('%F')
                                                  })
  end

  def page
    @page ||= params[:page]
  end

  def column
    @column ||= params[:column]
  end

  def direction
    @direction ||= params[:direction]
  end
end
