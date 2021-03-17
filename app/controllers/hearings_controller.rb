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
    # TODO: this should be hitting the hearing endpoint ideally, however, since pagination
    # currently requires having knowlegde of all hearings via the prosecution case endpoint
    # it is pointless and time-consuming to to query both endpoints when the prosecution case
    # endpoint contains all the info we need. If we could pass a "pagination collection" this would
    # allow us to revert to using the hearing endpoint.
    #
    @prosecution_case_search = Search.new(filter: 'case_reference', term: prosecution_case_reference)
    authorize! :create, @prosecution_case_search
  end

  def set_hearing
    hearing
  end

  def set_hearing_day
    hearing_day
  end

  def hearing
    @hearing ||= helpers.decorate(prosecution_case.hearings.find { |hearing| hearing.id == params[:id] })
  end

  def hearing_day
    @hearing_day ||= paginator.current_item.hearing_date || helpers.earliest_day_for(hearing)
  end

  def paginator
    @paginator ||= helpers.paginator(prosecution_case, sort_order: sort_order, page: page)
  end

  def prosecution_case
    @prosecution_case ||= helpers.decorate(@prosecution_case_search.execute.first)
  end

  def page
    @page ||= params[:page]
  end

  def sort_order
    @sort_order ||= params[:sort_order]
  end
end
