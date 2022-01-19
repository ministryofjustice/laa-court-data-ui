process.env.NODE_ENV = process.env.NODE_ENV || 'production'

const environment = require('./environment')

environment.config.merge({
  stats: 'errors-only'
})

module.exports = environment.toWebpackConfig()
