# frozen_string_literal: true

class ApplicationController < ActionController::Base
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder
  protect_from_forgery prepend: true, with: :exception
  before_action :authenticate_user!
  check_authorization

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden }
      format.html do
        flash[:alert] = exception.message
        redirect_to_back_or_default
      end
    end
  end

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
end
