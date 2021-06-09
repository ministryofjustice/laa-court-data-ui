const ANALYTICAL_COOKIES = [
  '_ga', '_gid'
]

const setConsentedToCookie = (usersAnswer) => {
  if (typeof usersAnswer === 'boolean') {
    setCookie('cookies_preferences_set', usersAnswer, {
      days: 30
    })
    removeOptionalCookies(usersAnswer)
    return true
  } else {
    throw new Error('consent-to-cookies: Only accepts boolean parameters')
  }
}

const fetchConsentedToCookieValue = () => {
  // Convert string to boolean value (Should be a boolean value)
  // Also a good safe guard if the value is anything than boolean
  // it will return false.
  return String(getCookie('cookies_preferences_set')) === 'true'
}

const checkConsentedToCookieExists = () => {
  return getCookie('cookies_preferences_set') != null
}

const cookieConsent = () => {
  return String(getCookie('cookies_preferences_set')) === 'true'
}

const removeAllPreviousUsedCookies = () => {
  const consentCookieExist = cookieConsent()

  const cookies = document.cookie.split(/;/)

  if (consentCookieExist === false) {
    for (let i = 0, len = cookies.length; i < len; i++) {
      const cookie = cookies[i].split(/=/)
      const cookieName = cookie[0].trim()
      if (cookieName !== '_laa_court_data_ui_session') {
        setCookie(cookieName, '', {
          days: -1
        })
      }
    }
  }
}

const removeOptionalCookies = (userDecision) => {
  if (userDecision === false) {
    ANALYTICAL_COOKIES.forEach(cookieName => {
      const doesCookieExist = getCookie(cookieName) != null

      if (doesCookieExist) {
        setCookie(cookieName, '', {
          days: -1
        })
      }
    })
  }
}

function getCookie (name) {
  const nameEQ = name + '='
  const cookies = document.cookie.split(';')
  for (let i = 0, len = cookies.length; i < len; i++) {
    let cookie = cookies[i]
    while (cookie.charAt(0) === ' ') {
      cookie = cookie.substring(1, cookie.length)
    }
    if (cookie.indexOf(nameEQ) === 0) {
      return decodeURIComponent(cookie.substring(nameEQ.length))
    }
  }
  return null
}

function setCookie (name, value, options) {
  if (typeof options === 'undefined') {
    options = {}
  }
  let cookieString = name + '=' + value + '; path=/; Domain=' + document.domain + ';'
  if (options.days) {
    const date = new Date()
    date.setTime(date.getTime() + (options.days * 24 * 60 * 60 * 1000))
    cookieString = cookieString + '; expires=' + date.toGMTString()
  }
  if (document.location.protocol === 'https:') {
    cookieString = cookieString + '; Secure'
  }
  document.cookie = cookieString
}

export {
  setConsentedToCookie,
  fetchConsentedToCookieValue,
  checkConsentedToCookieExists,
  cookieConsent,
  removeOptionalCookies,
  removeAllPreviousUsedCookies
}
