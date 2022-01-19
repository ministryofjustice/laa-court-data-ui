process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const environment = require('./environment')

environment.config.merge({
  stats: 'errors-only'
})

module.exports = environment.toWebpackConfig()
