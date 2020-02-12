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

  def set_back_page_path
    session[:back_page_path] = request.path
  end

  def redirect_to_back_or_default(options = {})
    redirect_to back_page_path, options
  end

  def back_page_path
    session[:back_page_path] || authenticated_root_path
  end
  helper_method :back_page_path

  def back_page_needed?
    controller_name.eql?('searches')
  end
  helper_method :back_page_needed?

  protected

  def access_denied(exception)
    respond_to do |format|
      format.json { head :forbidden }
      format.html do
        flash[:alert] = exception.message
        redirect_to_back_or_default
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
