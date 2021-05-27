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
    if (this.$form) {
      this.$on = document.querySelector('#ga_on')
      this.$off = document.querySelector('#ga_off')
      this.$get = window.location.search.substr(1)
      // Set cookies as per parameter
      if (this.$get) {
        this.$get === 'analytical-cookies=off' ? this.declineCookie() : this.$get === 'analytical-cookies=on' && this.acceptCookie();
      }
      // Set radio to cookie value
      this.$off.setAttribute('checked', 'checked')
      cookieConsent() && this.$on.setAttribute('checked', 'checked')
    }
  }
}
