const { defineConfig } = require('cypress')

module.exports = defineConfig({
  e2e: {
    Hblockosts: [
      "*.google-analytics.com"
    ],
    baseUrl: "https://staging.view-court-data.service.justice.gov.uk/",
    video: false
  }
})
