# frozen_string_literal: true

require_dependency 'court_data_adaptor'

# rubocop:disable Metrics/ClassLength
class HearingsController < ApplicationController
  before_action :load_and_authorize_search,
                :set_prosecution_case,
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
    redirect_to_prosecution_case(notice: I18n.t('hearings.show.flash.notice.no_hearing_details'))
  end

  def redirect_to_prosecution_case(**flash)
    redirect_back(fallback_location: prosecution_case_path(prosecution_case_reference),
                  allow_other_host: false,
                  **flash)
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
    @hearing ||= helpers.decorate(@prosecution_case.hearings.find do |hearing|
                                    hearing.id == params[:id]
                                  end, HearingDecorator)
  end

  def hearing_v2_call
    @hearing ||= helpers.decorate(
      CdApi::Hearing.find(params[:id], params: {
                            date: paginator.current_item.hearing_date.strftime('%F')
                          }), CdApi::HearingDecorator
    )
  rescue ActiveResource::ResourceNotFound
    redirect_to_prosecution_case(notice: I18n.t('hearings.show.flash.notice.no_hearing_details'))
  rescue ActiveResource::ServerError, ActiveResource::ClientError => e
    logger.error 'SERVER_ERROR_OCCURRED'
    Sentry.capture_exception(e)
    redirect_to_prosecution_case(alert: I18n.t('hearings.show.flash.notice.server_error'))
  end

  def hearing_v2
    logger.info 'USING_V2_ENDPOINT_HEARING'
    hearing_v2_call
  end

  def hearing_day
    @hearing_day ||= paginator.current_item.hearing_date || helpers.earliest_day_for(@hearing)
  end

  def paginator
    @paginator ||= helpers.paginator(@prosecution_case, column:, direction:, page:)
  end

  def set_prosecution_case
    Feature.enabled?(:hearing) ? prosecution_case_call_v2 : prosecution_case_call
  end

  def prosecution_case_call
    logger.info 'USING_V1_ENDPOINT_PROSECUTION_CASE'
    @prosecution_case = helpers.decorate(@prosecution_case_search.execute.first, ProsecutionCaseDecorator)
  end

  def prosecution_case_call_v2
    logger.info 'USING_V2_ENDPOINT_HEARING_SUMMARIES'
    @prosecution_case = helpers.decorate(@prosecution_case_search.call, CdApi::CaseSummaryDecorator)
  rescue ActiveResource::ServerError, ActiveResource::ClientError => e
    Rails.logger.error 'SERVER_ERROR_OCCURRED'
    Sentry.capture_exception(e)
    redirect_to_prosecution_case(alert: I18n.t('hearings.show.flash.notice.server_error'))
  end

  def hearing_events
    logger.info 'USING_V2_ENDPOINT_HEARING_EVENTS'
    @hearing_events ||= call_hearing_events
  end

  def call_hearing_events
    CdApi::Hearing.find(:one, params: {
                          date: paginator.current_item.hearing_date.strftime('%F')
                        }, from: "/hearings/#{params[:id]}/hearing_events")
  rescue ActiveResource::ResourceNotFound
    logger.info 'EVENTS_NOT_AVAILABLE'
    nil
  rescue ActiveResource::ServerError, ActiveResource::ClientError => e
    logger.error 'ERROR_CALLING_EVENTS'
    Sentry.capture_exception(e)
    show_alert(I18n.t('hearings.show.flash.notice.events_error'),
               "#{I18n.t('error.refresh')} #{I18n.t('error.it_helpdesk')}")
    nil
  end

  def show_alert(title, message)
    flash.now[:alert] = { title:, message: }
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
# rubocop:enable Metrics/ClassLength
