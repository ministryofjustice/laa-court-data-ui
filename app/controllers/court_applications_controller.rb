class CourtApplicationsController < ApplicationController
  DEFAULT_SORT_DIRECTION = "asc".freeze

  before_action :load_and_authorize_application

  add_breadcrumb :search_filter_breadcrumb_name, :new_search_filter_path
  add_breadcrumb :application_search_breadcrumb_name, :search_breadcrumb_path

  def show
    add_breadcrumb @application.application_title
    @date_sort_direction = params.fetch(:date_sort_direction, DEFAULT_SORT_DIRECTION)
  end

  private

  def load_and_authorize_application
    @application = CourtDataAdaptor::Query::CourtApplication.new(params[:id]).call
    authorize! :show, @application
  rescue JsonApiClient::Errors::ServiceUnavailable => e
    logger.error "COURT APPLICATION COULD NOT BE RETRIEVED: #{e.message}"
    Sentry.capture_exception(e)
    redirect_to controller: :errors, action: :internal_error
  rescue JsonApiClient::Errors::NotFound
    redirect_to controller: :errors, action: :not_found
  end
end
