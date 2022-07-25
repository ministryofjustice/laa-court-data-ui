# frozen_string_literal: true

module CookieConcern
  extend ActiveSupport::Concern

  def update_cookies
    cookie_params = params.permit(:cookies_preference, :hide_banner)

    render(partial: 'layouts/cookie_banner/hide') && return if params['hide_banner'] == 'true'

    update_analytics_cookies(cookie_params[:cookies_preference])

    render(partial: 'layouts/cookie_banner/success',
           locals: { analytics_cookies_accepted: cookies[:analytics_cookies_set] })
  end

  def set_default_cookies
    return set_default_analytics_cookies unless cookies[:cookies_preferences_set]

    @analytics_cookies_accepted = ActiveModel::Type::Boolean.new.cast(cookies[:analytics_cookies_set])
    show_hide_cookie_banners
  end

  private

  def update_analytics_cookies(preference)
    case preference
    when 'true'
      set_cookie(:analytics_cookies_set, value: true)
      @analytics_cookies_accepted = true
    else
      set_cookie(:analytics_cookies_set, value: false)
      remove_analytics_cookies
    end

    set_cookie(:cookies_preferences_set, value: true)
  end

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
