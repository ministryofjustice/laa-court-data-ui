# frozen_string_literal: true

class CookiesController < ApplicationController
  skip_before_action :authenticate_user!
  skip_authorization_check

  def new
    usage_cookie = cookies[:usage_opt_in]
    @cookie = Cookie.new(analytics: usage_cookie)
  end

  def create
    @cookie = Cookie.new(cookie_params[:cookie])
    if @cookie.valid?
      set_cookie(:usage_opt_in, value: @cookie.analytics)
      set_cookie(:cookies_preferences_set, value: true)
      flash[:success] = "You've set your cookie preferences."
      redirect_to cookies_settings_path
    else
      render :new
    end
  end

  def cookie_details; end

  private

  def cookie_params
    params.permit(cookie: :analytics)
  end
end
