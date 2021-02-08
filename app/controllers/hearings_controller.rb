# frozen_string_literal: true

require_dependency 'court_data_adaptor'

class HearingsController < ApplicationController
  before_action :load_and_authorize_search,
                :set_hearing,
                :set_hearing_day

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
    # TODO: pass the prosecution_case object from prosectuion_case
    # page/controller to speed up?!
    #
    @prosecution_case_search = Search.new(filter: 'case_reference', term: prosecution_case_reference)
    authorize! :create, @prosecution_case_search

    @hearing_search = CourtDataAdaptor::Query::Hearing.new(params[:id])
    authorize! :show, @hearing_search
  end

  def set_hearing
    hearing
  end

  def set_hearing_day
    hearing_day
  end

  def hearing
    @hearing ||= @hearing_search.call
  end

  def hearing_day
    @hearing_day ||= paginator.current_item.hearing_date || helpers.earliest_day_for(hearing)
  end

  def paginator
    @paginator ||= helpers.paginator(prosecution_case, page: page)
  end

  def prosecution_case
    @prosecution_case ||= @prosecution_case_search.execute.first
  end

  def page
    @page ||= params[:page]
  end
end
