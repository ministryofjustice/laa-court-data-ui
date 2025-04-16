class SubjectsController < ApplicationController
  before_action :load_and_authorize_application

  add_breadcrumb :search_filter_breadcrumb_name, :new_search_filter_path
  add_breadcrumb :search_breadcrumb_name, :search_breadcrumb_path

  def show
    add_breadcrumb @subject.name
  end

  private

  def load_and_authorize_application
    @application = CourtDataAdaptor::Query::CourtApplication.new(params[:court_application_id]).call
    @subject = @application.subject_summary
    authorize! :show, @application
  rescue JsonApiClient::Errors::ServiceUnavailable => e
    Sentry.capture_exception(e)
    redirect_to controller: :errors, action: :internal_error
  rescue JsonApiClient::Errors::NotFound
    redirect_to controller: :errors, action: :not_found
  end
end
