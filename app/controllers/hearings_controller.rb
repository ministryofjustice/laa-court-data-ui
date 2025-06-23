# frozen_string_literal: true

require_dependency 'court_data_adaptor'

class HearingsController < ApplicationController
  before_action :load_and_authorize_search,
                :set_prosecution_case,
                :set_hearing,
                :set_hearing_day,
                :set_hearing_events

  add_breadcrumb :search_filter_breadcrumb_name, :new_search_filter_path
  add_breadcrumb :search_breadcrumb_name, :search_breadcrumb_path
  add_breadcrumb proc { |v| v.prosecution_case_name(v.controller.prosecution_case_reference) },
                 proc { |v| v.prosecution_case_path(v.controller.prosecution_case_reference) }

  def show
    add_breadcrumb "#{t('generic.hearing_day')} #{hearing_day&.strftime('%d/%m/%Y')}", ''
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
    @prosecution_case_search = CourtDataAdaptor::CaseSummaryService.new(prosecution_case_reference)
    authorize! :create, @prosecution_case_search
  end

  def set_hearing
    hearing = Cda::Hearing.find(hearing_id)
    @hearing = helpers.decorate(hearing, Cda::HearingDecorator)
    @hearing.current_sitting_day = paginator.current_item.hearing_date.strftime('%F')
  rescue ActiveResource::ResourceNotFound
    # Return empty hearing so we can still display the page
    @hearing = helpers.decorate(Cda::Hearing.new, Cda::HearingDecorator)
  rescue ActiveResource::ServerError, ActiveResource::ClientError => e
    log_and_capture_error(e, 'SERVER_ERROR_OCCURRED')
    redirect_to_prosecution_case(alert: server_error_message(e))
  end

  def set_hearing_day
    hearing_day
  end

  def set_hearing_events
    @hearing_events ||= Cda::HearingEventLog.find_from_hearing_and_date(
      hearing_id,
      paginator.current_item.hearing_date.strftime('%F')
    )
  rescue ActiveResource::ResourceNotFound
    logger.info 'EVENTS_NOT_AVAILABLE'
  rescue ActiveResource::ServerError, ActiveResource::ClientError => e
    log_and_capture_error(e, 'ERROR_CALLING_EVENTS')
    show_alert(I18n.t('hearings.show.flash.notice.events_error'),
               "#{I18n.t('error.refresh')} #{I18n.t('error.it_helpdesk')}")
  end

  def hearing_params
    { date: paginator.current_item.hearing_date.strftime('%F') }
  end

  def log_and_capture_error(exception, log_messsage)
    logger.error log_messsage
    Sentry.capture_exception(exception)
  end

  def hearing_day
    @hearing_day ||= paginator.current_item.hearing_date || helpers.earliest_day_for(@hearing)
  end

  def paginator
    @paginator ||= helpers.paginator(@prosecution_case, column:, direction:, page:)
  end

  def set_prosecution_case
    logger.info 'USING_V2_ENDPOINT_CASE_SUMMARIES'
    @prosecution_case = helpers.decorate(@prosecution_case_search.call, Cda::CaseSummaryDecorator)
  rescue ActiveResource::ServerError, ActiveResource::ClientError => e
    log_and_capture_error(e, 'SERVER_ERROR_OCCURRED')
    redirect_to_prosecution_case(alert: server_error_message(e))
  end

  def show_alert(title, message)
    flash.now[:alert] = { title:, message: }
  end

  def server_error_message(exception)
    cda_error_string(exception) || I18n.t('hearings.show.flash.notice.server_error')
  end

  def hearing_id
    @hearing_id ||= params[:id]
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
