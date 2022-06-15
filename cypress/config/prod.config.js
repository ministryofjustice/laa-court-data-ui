const { defineConfig } = require('cypress')

module.exports = defineConfig({
  e2e: {
    Hblockosts: [
      "*.google-analytics.com"
    ],
    baseUrl: "https://view-court-data.service.justice.gov.uk/",
    video: false
  }
})
