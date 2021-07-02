# frozen_string_literal: true

class CookiesController < ApplicationController
  skip_before_action :authenticate_user!
  skip_authorization_check

  def new
    usage_cookie = cookies[:usage_opt_in]
    @cookie = Cookie.new(analytics: usage_cookie)
    store_previous_page_url
  end

  def create
    @cookie = Cookie.new(cookie_params[:cookie])
    if @cookie.valid?
      set_cookie(:usage_opt_in, value: @cookie.analytics)
      set_cookie(:cookies_preferences_set, value: true)
      previous_page_path = session.delete(:return_to)
      flash[:success] = t('cookie_settings.notification_banner.preferences_set', href: previous_page_path)
      redirect_to cookies_settings_path
    else
      render :new
    end
  end

  def cookie_details; end

  private

  def store_previous_page_url
    session[:return_to] = request.referrer
  end

  def cookie_params
    params.permit(cookie: :analytics)
  end
end
