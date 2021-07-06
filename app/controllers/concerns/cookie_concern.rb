# frozen_string_literal: true

module CookieConcern
  extend ActiveSupport::Concern

  private

  def set_default_cookies
    return set_default_analytics_cookies if no_analytics_cookies?

    if user_set_analytics_preference?
      set_cookie(:usage_opt_in, value: params[:usage_opt_in])
      set_cookie(:cookies_preferences_set, value: true)
    end

    set_analytics_cookies
    show_hide_cookie_banners
  end

  def set_cookie(type, value: false)
    cookies[type] = {
      value: value,
      domain: request.host,
      expires: Time.zone.now + 1.year
    }
  end

  def set_default_analytics_cookies
    set_cookie(:usage_opt_in)
  end

  def no_analytics_cookies?
    cookies[:usage_opt_in].nil?
  end

  def user_set_analytics_preference?
    params[:usage_opt_in].present?
  end

  def set_analytics_cookies
    @analytics_cookies_accepted = ActiveModel::Type::Boolean.new.cast(cookies[:usage_opt_in])
    return if @analytics_cookies_accepted

    remove_analytics_cookies
  end

  def remove_analytics_cookies
    cookies.delete :_ga, domain: request.host
    cookies.delete :_gid, domain: request.host
  end

  def show_hide_cookie_banners
    @cookies_preferences_set = cookies[:cookies_preferences_set]
    @show_confirm_banner = params[:show_confirm_banner].presence || false
  end
end
