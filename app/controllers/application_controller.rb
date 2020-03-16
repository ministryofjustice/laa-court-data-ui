# frozen_string_literal: true

class ApplicationController < ActionController::Base
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder
  protect_from_forgery prepend: true, with: :exception
  before_action :authenticate_user!
  check_authorization

  # Note: errors checked bottom to top
  # https://apidock.com/rails/v6.0.0/ActiveSupport/Rescuable/ClassMethods/rescue_from
  rescue_from Exception, with: :unexpected_exception_handler
  rescue_from CanCan::AccessDenied, with: :access_denied

  def current_search_filter=(arg)
    session[:current_search_filter] = arg
  end

  def current_search_filter
    session[:current_search_filter]
  end
  helper_method :current_search_filter

  def search_breadcrumb_name
    case current_search_filter
    when 'case_reference'
      'Case ref search'
    when 'defendant_reference'
      'Defendant ref search'
    when 'defendant_name'
      'Defendant name search'
    end
  end
  helper_method :search_breadcrumb_name

  def search_breadcrumb_path
    new_search_path(search: { filter: current_search_filter })
  end
  helper_method :search_breadcrumb_path

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
    when ActiveRecord::RecordNotFound || ActionController::RoutingError
      redirect_to controller: :errors, action: :not_found
    when JsonApiClient::Errors::NotAuthorized
      redirect_to controller: :errors, action: :unauthorized
    else
      redirect_to controller: :errors, action: :internal_error
    end
  end
end
