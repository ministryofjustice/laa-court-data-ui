import {
  loadAnalytics
} from './analytics'
import {
  setConsentedToCookie,
  checkConsentedToCookieExists,
  cookieConsent,
  removeOptionalCookies,
  removeAllPreviousUsedCookies
} from './cookie-helper'

export default class CookieBanner {
  constructor () {
    this.$module = document.querySelector('[data-module="app-cookie-banner"]')
    this.$form = document.querySelector('#cookie-form')

    // If the page doesn't have the banner then stop
    if (!this.$module) {
      return
    }

    this.acceptButton = this.$module.querySelector('[data-accept-cookies="true"]')
    this.closeButton = this.$module.querySelector('[data-reject-cookies="true"]')

    // consentCookie is false if user has not accept/rejected cookies
    if (!checkConsentedToCookieExists()) {
      removeAllPreviousUsedCookies()
      this.showCookieMessage()
      this.bindEvents()
    }

    if (!cookieConsent()) {
      removeOptionalCookies(cookieConsent())
    }

    this.checkCookies()
  }

  bindEvents () {
    this.acceptButton.addEventListener('click', () => this.acceptCookie())
    this.closeButton.addEventListener('click', () => this.declineCookie())
  }

  acceptCookie () {
    this.hideCookieMessage()
    setConsentedToCookie(true)
    loadAnalytics()
  }

  declineCookie () {
    this.hideCookieMessage()
    removeOptionalCookies(false)
    setConsentedToCookie(false)
  }

  showCookieMessage () {
    this.$module.classList.remove('app-cookie-banner--hidden')
  }

  hideCookieMessage () {
    this.$module.classList.add('app-cookie-banner--hidden')
  }

  checkCookies () {
    // If this is the cookie settings page and a parameter is set
    if (window.location.search.substr(1) === 'analytical-cookies=off') {
      this.declineCookie()
    } else if (window.location.search.substr(1) === 'analytical-cookies=on') {
      this.acceptCookie()
    }
    /*
    // If cookie set and on radio page, set radio accordingly
    if (document.querySelector('#new_cookie')) {
      document.querySelector('#cookie-analytics-0-field').setAttribute('checked', 'checked')
      if (cookieConsent()) {
        document.querySelector('#cookie-analytics-1-field').setAttribute('checked', 'checked')
      }
    }
    */
  }
}
