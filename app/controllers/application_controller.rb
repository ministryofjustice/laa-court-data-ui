# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Breadcrumbs
  include CookieConcern # Needs to be here for cookie_settings page

  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder
  protect_from_forgery prepend: true, with: :exception
  before_action :authenticate_user!, :set_transaction_id
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
    when ActiveRecord::RecordNotFound, ActionController::RoutingError
      redirect_to controller: :errors, action: :not_found
    when JsonApiClient::Errors::NotAuthorized
      redirect_to controller: :errors, action: :unauthorized
    when JsonApiClient::Errors::ConnectionError, Net::ReadTimeout, ActiveResource::ForbiddenAccess,
      ActiveResource::ServerError, ActiveResource::TimeoutError
      Sentry.capture_exception(exception)
      flash[:alert] = I18n.t('error.connection_error_message', it_helpdesk: I18n.t('error.it_helpdesk'))
      redirect_to authenticated_root_path
    else
      Sentry.capture_exception(exception)
      redirect_to controller: :errors, action: :internal_error
    end
  end

  def set_transaction_id
    Current.request_id = request.headers['laa-transaction-id'] || request.request_id
    response.set_header('laa-transaction-id', Current.request_id)
  end
end
