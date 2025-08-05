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
    @search = Search.new(filter:, term:, dob:)
    authorize! :create, @search

    @results = helpers.decorate_all(@search.execute, Cda::DefendantSummaryDecorator) if @search.valid?
    render 'new'
  rescue ActiveResource::ClientError => e
    Rails.logger.info 'CLIENT_ERROR_OCCURRED'
    handle_client_error e
  rescue ActiveResource::ServerError => e
    Rails.logger.error 'SERVER_ERROR_OCCURRED'
    handle_server_error e
  end

  private

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
    @dob ||= DobFieldCollection.new(search_params)
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
    logger.error 'CLIENT_ERROR_OCCURRED'
    log_sentry_error(exception, exception.response.try(:body))
    render_error(I18n.t('search.error.unprocessable'),
                 cda_error_string(exception) || I18n.t('error.it_helpdesk'))
  end

  def handle_server_error(exception)
    logger.error 'SERVER_ERROR_OCCURRED'
    log_sentry_error(exception, exception.response.try(:body))
    render_error(I18n.t('search.error.failure'), cda_error_string(exception) || I18n.t('error.it_helpdesk'))
  end

  def render_error(title, message)
    flash.now[:alert] = { title:, message: }
    render 'new'
  end
end
