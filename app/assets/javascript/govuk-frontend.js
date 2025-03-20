import { initAll } from 'govuk-frontend'

document.addEventListener('turbo:load', function (event) {
  require.context('govuk-frontend/dist/govuk/assets')
  initAll()
})
