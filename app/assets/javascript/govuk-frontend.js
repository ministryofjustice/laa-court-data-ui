import { initAll } from 'govuk-frontend'

document.addEventListener('turbo:load', function (event) {
  require.context('govuk-frontend/govuk/assets')
  initAll()
})
