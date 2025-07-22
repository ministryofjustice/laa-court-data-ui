class CourtApplicationsController < ApplicationController
  DEFAULT_SORT_DIRECTION = "asc".freeze

  before_action :load_and_authorize_application

  add_breadcrumb :search_filter_breadcrumb_name, :new_search_filter_path
  add_breadcrumb :search_breadcrumb_name, :search_breadcrumb_path
  add_breadcrumb proc { |v| v.prosecution_case_name(v.controller.prosecution_case_reference) },
                 proc { |v| v.prosecution_case_path(v.controller.prosecution_case_reference) }

  def show
    add_breadcrumb t('subjects.appeal')
    @date_sort_direction = params.fetch(:date_sort_direction, DEFAULT_SORT_DIRECTION)
  end

  def prosecution_case_reference
    @application.prosecution_case_reference
  end

  private

  def load_and_authorize_application
    @application = Cda::CourtApplication.find(params[:id])
    authorize! :show, @application
  rescue JsonApiClient::Errors::ServiceUnavailable => e
    logger.error "COURT APPLICATION COULD NOT BE RETRIEVED: #{e.message}"
    Sentry.capture_exception(e)
    redirect_to controller: :errors, action: :internal_error
  rescue JsonApiClient::Errors::NotFound
    redirect_to controller: :errors, action: :not_found
  end
end
