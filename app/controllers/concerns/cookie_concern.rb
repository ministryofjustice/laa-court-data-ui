# frozen_string_literal: true

module CookieConcern
  extend ActiveSupport::Concern

  private

  def set_default_cookies
    return set_default_analytics_cookies if no_analytics_cookies?

    if user_set_analytics_preference?
      set_cookie(:analytics_cookies_set, value: params[:analytics_cookies_set])
      set_cookie(:cookies_preferences_set, value: true)
    end

    set_analytics_cookies
    show_hide_cookie_banners
  end

  def set_cookie(type, value: false)
    cookies[type] = {
      value: value,
      domain: request.host,
      expires: 1.year.from_now,
      secure: !Rails.env.test?
    }
  end

  def set_default_analytics_cookies
    set_cookie(:analytics_cookies_set)
  end

  def no_analytics_cookies?
    cookies[:analytics_cookies_set].nil?
  end

  def user_set_analytics_preference?
    params[:analytics_cookies_set].present?
  end

  def set_analytics_cookies
    @analytics_cookies_accepted = ActiveModel::Type::Boolean.new.cast(cookies[:analytics_cookies_set])
    return if @analytics_cookies_accepted

    remove_analytics_cookies
  end

  def remove_analytics_cookies
    cookies.delete :_ga, domain: '.justice.gov.uk'
    cookies.delete :_gid, domain: '.justice.gov.uk'
  end

  def show_hide_cookie_banners
    @cookies_preferences_set = cookies[:cookies_preferences_set]
    @show_confirm_banner = params[:show_confirm_banner].present?
  end
end
