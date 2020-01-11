# frozen_string_literal: true

class ApplicationController < ActionController::Base
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder
  protect_from_forgery prepend: true, with: :exception

  def set_back_page_path
    session[:back_page_path] = request.path
  end

  def redirect_to_back_or_default
    redirect_to back_page_path
  end

  def back_page_path
    session[:back_page_path] || root_path
  end
  helper_method :back_page_path
end
