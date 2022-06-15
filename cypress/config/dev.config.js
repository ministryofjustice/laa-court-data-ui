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
    environment: 'develop',
    caseworker_password: '',
    manager_password: '',
    admin_password: ''
  }
})
