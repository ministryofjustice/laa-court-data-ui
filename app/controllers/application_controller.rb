# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Breadcrumbs
  include CookieConcern

  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder
  protect_from_forgery prepend: true, with: :exception
  before_action :authenticate_user!, :set_default_cookies
  check_authorization

  # NOTE: errors checked bottom to top
  # https://apidock.com/rails/v6.0.0/ActiveSupport/Rescuable/ClassMethods/rescue_from
  rescue_from Exception, with: :unexpected_exception_handler
  rescue_from CanCan::AccessDenied, with: :access_denied

  def current_search_params=(params)
    session[:current_search_params] = params
  end

  def current_search_params
    session[:current_search_params]
  end
  helper_method :current_search_params

  protected

  def access_denied(exception)
    respond_to do |format|
      format.json { head :forbidden }
      format.html do
        flash[:alert] = exception.message
        redirect_to authenticated_root_path
      end
    end
  end

  def unexpected_exception_handler(exception)
    raise unless Rails.env.production?

    case exception
    when ActiveRecord::RecordNotFound
      Sentry.capture_exception(exception)
      redirect_to_not_found
    when ActionController::RoutingError
      redirect_to_not_found
    when JsonApiClient::Errors::NotAuthorized
      redirect_to controller: :errors, action: :unauthorized
    else
      Sentry.capture_exception(exception)
      redirect_to controller: :errors, action: :internal_error
    end
  end

  def redirect_to_not_found
    redirect_to controller: :errors, action: :not_found
  end
end
