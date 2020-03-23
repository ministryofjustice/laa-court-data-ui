# frozen_string_literal: true

class SearchesController < ApplicationController
  before_action :set_view_options

  rescue_from JsonApiClient::Errors::ConnectionError, with: :connection_error

  add_breadcrumb :new_search_filter_name, :new_search_filter_path
  add_breadcrumb :search_breadcrumb_name, :search_breadcrumb_path

  def new
    @search = Search.new
    authorize! :new, @search
  end

  def create
    @search = Search.new(filter: filter, term: term, dob: dob)
    authorize! :create, @search

    @results = @search.execute if @search.valid?
    render 'new'
  end

  def connection_error
    @error = I18n.t('search.connection_error')
    render 'new'
  end

  private

  def search_params
    params.require(:search).permit(:term, :dob, :filter)
  end

  def filter
    @filter ||= search_params[:filter] || 'case_reference'
  end

  def term
    @term ||= search_params[:term]
  end

  def dob
    return @dob if @dob
    year = search_params['dob(1i)']
    month = search_params['dob(2i)']
    day = search_params['dob(3i)']
    @dob = Date.parse([day, month, year].join('-')) \
      if day.present? && month.present? && year.present?
  rescue Date::Error
    nil
  end

  def set_view_options
    case filter
    when 'defendant_reference'
      @label = I18n.t('search.term.defendant_reference_label')
      @hint = I18n.t('search.term.defendant_reference_label_hint')
    when 'defendant_name'
      @label = I18n.t('search.term.defendant_name_label')
      @hint = I18n.t('search.term.defendant_name_label_hint')
    else
      @label = I18n.t('search.term.case_reference_label')
      @hint = I18n.t('search.term.case_reference_label_hint')
    end
  end
end
