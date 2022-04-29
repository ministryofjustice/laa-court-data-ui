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

    return if hearing

    redirect_back(fallback_location: prosecution_case_path(prosecution_case_reference),
                  allow_other_host: false,
                  notice: I18n.t('hearings.show.flash.notice.no_hearing_details'))
  end

  def prosecution_case_reference
    @prosecution_case_reference ||= params[:urn]
  end

  private

  def load_and_authorize_search
    # TODO: this should be hitting the hearing endpoint ideally, however, since pagination
    # currently requires having knowlegde of all hearings via the prosecution case endpoint
    # it is pointless and time-consuming to to query both endpoints when the prosecution case
    # endpoint contains all the info we need. If we could pass a "pagination collection" this would
    # allow us to revert to using the hearing endpoint.

    @prosecution_case_search = Search.new(filter: 'case_reference', term: prosecution_case_reference)
    authorize! :create, @prosecution_case_search
  end

  def set_hearing
    hearing
  end

  def set_hearing_day
    hearing_day
  end

  def set_hearing_events
    hearing_events if Feature.enabled?(:hearing_events)
  end

  def hearing
    @hearing ||= if Feature.enabled?(:hearing_data)
                   CdApi::Hearing.find(params[:id], params: {
                                         date: paginator.current_item.hearing_date.strftime('%F')
                                       })
                 else
                   helpers.decorate(prosecution_case.hearings.find { |hearing| hearing.id == params[:id] })
                 end
  end

  def hearing_day
    @hearing_day ||= paginator.current_item.hearing_date || helpers.earliest_day_for(hearing)
  end

  def paginator
    @paginator ||= helpers.paginator(prosecution_case, column:,
                                                       direction:, page:)
  end

  def prosecution_case
    @prosecution_case ||= helpers.decorate(@prosecution_case_search.execute.first)
  end

  def hearing_events
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
