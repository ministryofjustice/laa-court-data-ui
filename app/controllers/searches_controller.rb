# frozen_string_literal: true

class SearchesController < ApplicationController
  before_action :set_search_options

  rescue_from JsonApiClient::Errors::ConnectionError, with: :connection_error

  add_breadcrumb :search_filter_breadcrumb_name, :new_search_filter_path
  add_breadcrumb :search_breadcrumb_name, :search_breadcrumb_path

  def new
    @search = Search.new
    authorize! :new, @search
  end

  def create
    @search = Search.new(filter: filter, term: term, dob: dob)
    authorize! :create, @search

    @results = search_results
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

  def search_results
    Rails.cache.fetch(term, expires_in: Rails.configuration.cache_expiry) do
      @search.execute if @search.valid?
    end
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

  def set_search_options
    filter
    term
    dob
    set_view_options
    self.current_search_params = search_params
  end

  def set_view_options
    @label = case filter
             when 'defendant_reference'
               I18n.t('search.term.defendant_reference_label')
             when 'defendant_name'
               I18n.t('search.term.defendant_name_label')
             else
               I18n.t('search.term.case_reference_label')
             end
  end
end
