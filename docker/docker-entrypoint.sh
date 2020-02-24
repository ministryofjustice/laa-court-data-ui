#!/bin/sh

set -ex

printf '\e[33mINFO: DB migrate\e[0m\n'
RUBYOPT=-W:no-deprecated bundle exec rails db:create db:migrate

# if REDIS_URL is not set then we start redis-server locally
if [ -z ${REDIS_URL+x} ]; then
  printf '\e[33mINFO: Starting redis-server daemon\e[0m\n'
  redis-server --daemonize yes
else
  printf '\e[33mINFO: Using remote redis-server specified in REDIS_URL\e[0m\n'
fi

printf '\e[33mINFO: Starting sidekiq daemon\e[0m\n'
bundle exec sidekiq -d

# NOTE: "RUBYOPT=-W:no-deprecated" removes verbose
# warnings raised by rails using ruby 2.7
#
printf '\e[33mINFO: Launching puma\e[0m\n'
RUBYOPT=-W:no-deprecated bundle exec puma
