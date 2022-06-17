# frozen_string_literal: true

module CookieConcern
  extend ActiveSupport::Concern

  def test
    cookie_params = params.permit(:cookies)

    case cookie_params[:cookies]
    when 'Accept analytics cookies'
      set_cookie(:analytics_cookies_set, value: true)
    else
      set_cookie(:analytics_cookies_set, value: false)
      remove_analytics_cookies
    end

    @analytics_cookies_accepted = cookies[:analytics_cookies_set]

    set_cookie(:cookies_preferences_set, value: true)
    render partial: 'layouts/something'
  end

  private

  def set_default_cookies
    return set_default_analytics_cookies if !cookies[:cookies_preferences_set] #no pref set


    show_hide_cookie_banners # to set whether banner partial should show up
  end

  # def set_default_cookiesx
  #   return set_default_analytics_cookies if no_analytics_cookies?

  #   if user_set_analytics_preference?
  #     set_cookie(:analytics_cookies_set, value: params[:analytics_cookies_set])
  #     set_cookie(:cookies_preferences_set, value: true)
  #   end

  #   set_analytics_cookies
  #   show_hide_cookie_banners
  # end

  def set_cookie(type, value: false)
    cookies[type] = {
      value:,
      domain: request.host,
      expires: 1.year.from_now,
      secure: !Rails.env.test?
    }
  end

  def set_default_analytics_cookies
    set_cookie(:analytics_cookies_set)
  end

  # def no_analytics_cookies?
  #   cookies[:analytics_cookies_set].nil?
  # end

  # def user_set_analytics_preference?
  #   params[:analytics_cookies_set].present?
  # end

  # def set_analytics_cookies
  #   @analytics_cookies_accepted = ActiveModel::Type::Boolean.new.cast(cookies[:analytics_cookies_set])
  #   return if @analytics_cookies_accepted

  #   remove_analytics_cookies
  # end

  def remove_analytics_cookies
    cookies.delete :_ga, domain: '.justice.gov.uk'
    cookies.delete :_gid, domain: '.justice.gov.uk'
  end

  def show_hide_cookie_banners
    @cookies_preferences_set = cookies[:cookies_preferences_set]
  end
end
