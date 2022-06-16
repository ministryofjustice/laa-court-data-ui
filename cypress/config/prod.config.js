const { defineConfig } = require('cypress')

module.exports = defineConfig({
  e2e: {
    blockHosts: [
      '*.google-analytics.com'
    ],
    baseUrl: 'https://view-court-data.service.justice.gov.uk/',
    video: false
  },
  env: {
    environment: 'alpha',
    caseworker_password: '',
    manager_password: '',
    admin_password: ''
  },
  setupNodeEvents (on, _config) {
    on('task', {
      log (message) {
        console.log(message)
        return null
      },
      table (message) {
        console.table(message)
        return null
      }
    })
  }
})
