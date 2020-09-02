# frozen_string_literal: true

require_dependency 'court_data_adaptor'

class HearingsController < ApplicationController
  before_action :load_and_authorize_search,
                :set_hearing

  add_breadcrumb :search_filter_breadcrumb_name, :new_search_filter_path
  add_breadcrumb :search_breadcrumb_name, :search_breadcrumb_path
  add_breadcrumb (proc { |v| v.prosecution_case_name(v.controller.prosecution_case_reference) }),
                 (proc { |v| v.prosecution_case_path(v.controller.prosecution_case_reference) })

  def show
    add_breadcrumb "Hearing #{@hearing_day&.strftime('%d/%m/%Y')}", ''

    return if @hearing

    redirect_back(fallback_location: prosecution_case_path(prosecution_case_reference),
                  allow_other_host: false,
                  notice: I18n.t('hearings.show.flash.notice.no_hearing_details'))
  end

  def prosecution_case_reference
    params[:urn]
  end

  private

  def load_and_authorize_search
    @hearing_search = CourtDataAdaptor::Query::Hearing.new(params[:id])
    authorize! :show, @hearing_search
  end

  def set_hearing
    @hearing = @hearing_search.call
    @hearing_day = @hearing&.hearing_days&.first&.to_datetime
  end
end
