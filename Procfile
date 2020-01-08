# This is intended for heroku deployment
# for local development use `Procfile.dev` instead
# for local heroku - run `heroku local`
#
web: RUBYOPT=-W:no-deprecated bundle exec puma -C config/puma.rb
assets: bin/webpack-dev-server
