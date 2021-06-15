# frozen_string_literal: true

class CookiesController < ApplicationController
  skip_before_action :authenticate_user!
  skip_authorization_check

  def new
    @cookie = Cookie.new
  end

  def create
    @cookie = Cookie.new(cookie_params[:cookie])
    if @cookie.valid?
      flash[:success] = 'XYZ'
    else
      flash[:error] = 'Else'
    end
    render :new
  end

  def cookie_details; end

  private

  def cookie_params
    params.permit(cookie: :analytics)
  end
end
