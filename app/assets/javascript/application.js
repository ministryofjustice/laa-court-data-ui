/* global Turbo */
import '../stylesheets/application.scss'
import '@hotwired/turbo'

import Rails from '@rails/ujs'
import { initAll } from 'govuk-frontend'
import * as MOJFrontend from '@ministryofjustice/frontend'

// Prevent turbo from intercepting form submissions in ways that don't play nicely
// with things like the Rails flash system, unless it's explicitly asked for. Note:
// 1) This avoids the need for having to a add a `data-turbo=false` annotation to
//    individual forms
// 2) This doesn't disable turbo as a whole, so it will still do link-prefetching,
//    and the turbo-frame system used for the cookie banner will still work.
// 3) the `data-turbo-method="delete" annotation on anchors is controlled by this setting,
//    so switching this to "off" would disable those.
Turbo.config.forms.mode = 'optin'

Rails.start()

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

const setUpEventListeners = () => {
  initAll()
  MOJFrontend.initAll()

  document.querySelector('.search-form-toggle')?.addEventListener('click', () => {
    document.querySelectorAll('.search-form-element').forEach((element) => {
      element.classList.remove('moj-js-hidden')
    })
    document.querySelector('.search-form-toggle').classList.add('moj-js-hidden')
  })
  document.querySelector('.hide-search-form-toggle')?.addEventListener('click', () => {
    document.querySelectorAll('.search-form-element').forEach((element) => {
      element.classList.add('moj-js-hidden')
    })
    document.querySelector('.search-form-toggle').classList.remove('moj-js-hidden')
  })

  const clearDatesLink = document.getElementById('clear-dates')
  if (clearDatesLink) {
    clearDatesLink.addEventListener('click', (event) => {
      event.preventDefault()

      const fromField = document.getElementById('stat-range-from-field')
      const toField = document.getElementById('stat-range-to-field')

      if (fromField) fromField.value = ''
      if (toField) toField.value = ''
    })
  }
}

document.addEventListener('DOMContentLoaded', setUpEventListeners)
document.addEventListener('turbo:render', setUpEventListeners)
