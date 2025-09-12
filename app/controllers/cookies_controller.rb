# frozen_string_literal: true

class CookiesController < ApplicationController
  skip_before_action :authenticate_user!
  skip_authorization_check

  def new
    usage_cookie = cookies[:analytics_cookies_set]
    @cookie = Cookie.new(analytics: usage_cookie)
    store_previous_page_url
  end

  def create
    @cookie = Cookie.new(cookie_params[:cookie])
    if @cookie.valid?
      set_cookies
      set_flash_notification
      redirect_to cookies_settings_path
    else
      render :new
    end
  end

  def cookie_details; end

  private

  def set_cookies
    set_cookie(:analytics_cookies_set, value: @cookie.analytics)
    set_cookie(:cookies_preferences_set, value: true)
  end

  def set_flash_notification
    previous_page_path = session.delete(:return_to)
    flash[:success] = t('cookie_settings.notification_banner.preferences_set_html', href: previous_page_path)
  end

  def store_previous_page_url
    session[:return_to] = session_safe(request.referrer, max_string_length: 200)
  end

  def cookie_params
    params.permit(cookie: :analytics)
  end
end
