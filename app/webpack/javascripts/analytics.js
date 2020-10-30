import {
  fetchConsentedToCookieValue
} from './cookie-helper'

/**
 * load analytics if consent is granted
 */
const loadAnalytics = () => {
  if (fetchConsentedToCookieValue()) {
    const analyticsScriptTag = document.createElement('script')
    analyticsScriptTag.async = ''
    analyticsScriptTag.src = `https://www.googletagmanager.com/gtag/js?id=${googleTrackingID}`
    document.head.appendChild(analyticsScriptTag)

    window.dataLayer = window.dataLayer || []

    function gtag() { // eslint-disable-line
      dataLayer.push(arguments)
    }
    gtag('js', new Date())
    gtag('config', `${googleTrackingID}`, {
      anonymize_ip: true
    })
  }
}

export {
  loadAnalytics
}
