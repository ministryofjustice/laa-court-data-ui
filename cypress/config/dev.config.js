const { defineConfig } = require('cypress')

module.exports = defineConfig({
  e2e: {
    blockHosts: [
      '*.google-analytics.com'
    ],
    baseUrl: 'https://dev.view-court-data.service.justice.gov.uk/',
    video: false
  },
  env: {
    environment: 'develop'
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
