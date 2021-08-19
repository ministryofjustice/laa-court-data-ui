const { environment } = require('@rails/webpacker')

environment.config.merge({
  output: {
    filename: 'js/[name]-[hash].js'
  }
})

module.exports = environment
