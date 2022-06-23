# frozen_string_literal: true

module CookieConcern
  extend ActiveSupport::Concern

  def update_cookies # Rename this and the related _something file
    cookie_params = params.permit(:cookies_preference, :hide_banner)

    render(partial: 'layouts/cookie_banner/hide') && return if params['hide_banner'] == 'true'

    case cookie_params[:cookies_preference]
    when 'true'
      set_cookie(:analytics_cookies_set, value: true)
      @analytics_cookies_accepted = true
    else
      set_cookie(:analytics_cookies_set, value: false)
      remove_analytics_cookies
    end

    @analytics_cookies_accepted = cookies[:analytics_cookies_set]

    set_cookie(:cookies_preferences_set, value: true)

    render(partial: 'layouts/cookie_banner/success')
  end

  def set_default_cookies
    return set_default_analytics_cookies if !cookies[:cookies_preferences_set] # no pref set

    @analytics_cookies_accepted = ActiveModel::Type::Boolean.new.cast(cookies[:analytics_cookies_set])
    show_hide_cookie_banners # to set whether banner partial should show up
  end

  private

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

  def remove_analytics_cookies
    cookies.delete :_ga, domain: '.justice.gov.uk'
    cookies.delete :_gid, domain: '.justice.gov.uk'
  end

  def show_hide_cookie_banners
    @cookies_preferences_set = cookies[:cookies_preferences_set]
  end
end
