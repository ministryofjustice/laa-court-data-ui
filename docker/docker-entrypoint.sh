#!/bin/sh

set -ex

printf '\e[33mINFO: DB migrate\e[0m\n'
RUBYOPT=-W:no-deprecated bundle exec rails db:create db:migrate

# NOTE: "RUBYOPT=-W:no-deprecated" removes verbose
# warnings raised by rails using ruby 2.7
#
printf '\e[33mINFO: Launching puma\e[0m\n'
RUBYOPT=-W:no-deprecated bundle exec puma
