# frozen_string_literal: true

module CookieConcern
  extend ActiveSupport::Concern

  private

  def set_default_cookies
    return set_cookie(:usage_opt_in) if cookies[:usage_opt_in].nil?

    if params[:usage_opt_in].present?
      set_cookie(:usage_opt_in, value: booleanise_usage_opt_in)
      set_cookie(:cookies_preferences_set, value: true)
    end

    analytics_cookies_accepted?
    show_hide_cookie_banners
  end

  def set_cookie(type, value: false)
    cookies[type] = {
      value: value,
      domain: request.host,
      expires: Time.zone.now + 1.year,
      secure: !Rails.env.test?
    }
  end

  def booleanise_usage_opt_in
    ActiveModel::Type::Boolean.new.cast(params[:usage_opt_in])
  end

  def cookies_preferences_set?
    cookies[:cookies_preferences_set]
  end

  def analytics_cookies_accepted?
    @analytics_cookies_accepted = ActiveModel::Type::Boolean.new.cast(cookies[:usage_opt_in])
    return if @analytics_cookies_accepted
    cookies.delete :_ga
    cookies.delete :_gid
  end

  def show_hide_cookie_banners
    @cookies_preferences_set = cookies_preferences_set?
    @show_confirm_banner = params[:show_confirmation].presence || false
  end
end
