# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Breadcrumbs
  include CookieConcern # Needs to be here for cookie_settings page
  include Pagy::Backend

  HOURS_OF_OPERATION = 7...22

  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder
  protect_from_forgery prepend: true, with: :exception
  before_action :detect_out_of_hours, :detect_maintenance_mode
  before_action :authenticate_user!, :set_transaction_id, :set_default_cookies
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

  EXPECTED_ERROR_TYPES = [
    Net::ReadTimeout,
    ActiveResource::ConnectionError
  ].freeze

  def unexpected_exception_handler(exception)
    raise if Rails.env.development?

    logger.error("Unexpected #{exception.class} error: #{exception}")
    process_error_based_on_type(exception)
  end

  def process_error_based_on_type(exception)
    Sentry.capture_exception(exception)
    case exception
    when *EXPECTED_ERROR_TYPES
      assign_error_flash(exception)
      redirect_to authenticated_root_path
    else
      redirect_to internal_error_path
    end
  end

  def assign_error_flash(exception)
    flash[:alert] = I18n.t('error.connection_error_message',
                           details: cda_error_string(exception) || I18n.t('error.it_helpdesk'))
  end

  def set_transaction_id
    Current.request_id = request.headers['laa-transaction-id'] || request.request_id
    response.set_header('laa-transaction-id', Current.request_id)
  end

  def log_sentry_error(exception, errors)
    Sentry.with_scope do |scope|
      scope&.set_extra('error_message', errors)
      Sentry.capture_exception(exception)
    end
  end

  def detect_out_of_hours
    return unless FeatureFlag.enabled?(:out_of_hours)

    render "errors/out_of_hours" unless Time.now.in_time_zone("London").hour.in?(HOURS_OF_OPERATION)
  end

  def detect_maintenance_mode
    render "maintenance_mode/show", layout: false if FeatureFlag.enabled?(:maintenance_mode)
  end

  def cda_error_string(exception)
    Cda::ErrorCodeParser.call(exception.try(:response), cda_error_string_context)
  end

  def cda_error_string_context
    nil
  end
end
