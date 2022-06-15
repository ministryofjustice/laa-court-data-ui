const { defineConfig } = require('cypress')

module.exports = defineConfig({
  e2e: {
    blockHosts: [
      '*.google-analytics.com'
    ],
    baseUrl: 'http://localhost:3000',
    video: false
  },
  env: {
    environment: 'local',
    caseworker_password: '',
    manager_password: '',
    admin_password: ''
  }
})
