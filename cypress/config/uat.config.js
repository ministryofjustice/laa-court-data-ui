const { defineConfig } = require('cypress')

module.exports = defineConfig({
  e2e: {
    Hblockosts: [
      "*.google-analytics.com"
    ],
    baseUrl: "https://uat.view-court-data.service.justice.gov.uk/",
    video: false
  },
  env: {
    environment: "uat",
    caseworker_password: "",
    manager_password: "",
    admin_password: ""
  }
})
