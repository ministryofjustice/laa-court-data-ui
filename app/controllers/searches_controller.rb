# frozen_string_literal: true

class SearchesController < ApplicationController
  before_action :set_search_options, :handle_empty_search_params

  add_breadcrumb :search_filter_breadcrumb_name, :new_search_filter_path
  add_breadcrumb :search_breadcrumb_name, :search_breadcrumb_path

  def new
    @search = Search.new
    authorize! :new, @search
  end

  def create
    @search = Search.new(filter:, term:, dob:, version2: version_2?)
    authorize! :create, @search

    @results = @search.execute if @search.valid?
    render 'new'
  rescue ActiveResource::BadRequest => e
    Rails.logger.info 'CLIENT_ERROR_OCCURRED'
    handle_client_error e
  rescue ActiveResource::ServerError, ActiveResource::ClientError => e
    Rails.logger.error 'SERVER_ERROR_OCCURRED'
    handle_server_error e
  end

  private

  def version_2?
    Feature.enabled?(:defendants_search)
  end

  def search_params
    params.fetch(:search, most_recent_search_params).permit(:term, :dob, :filter)
  end

  def most_recent_search_params
    current_search_params || {} # Default to empty search params
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

  def handle_empty_search_params
    redirect_to new_search_filter_path if search_params.empty?
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

  def handle_client_error(exception)
    logger.info 'CLIENT_ERROR_OCCURRED'
    @laa_reference.errors.from_json(exception.response.body)
    render_error(I18n.t('search.error.unprocessable'), @laa_reference&.errors&.full_messages&.join(', '))
  end

  def handle_server_error(exception)
    logger.error 'SERVER_ERROR_OCCURRED'
    log_sentry_error(exception, @laa_reference&.errors)
    render_error(I18n.t('search.error.failure'), I18n.t('error.it_helpdesk'))
  end

  def render_error(title, message)
    flash.now[:alert] = { title:, message: }
    render 'new'
  end
end
