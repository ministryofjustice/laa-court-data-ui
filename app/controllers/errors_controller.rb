# frozen_string_literal: true

class ErrorsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_authorization_check

  respond_to :html

  def unauthorized
    render status: :unauthorized
  end

  def not_found
    render status: :not_found
  end

  def unacceptable
    render status: :unprocessable_entity
  end

  def internal_error
    render status: :internal_server_error
  end
end
