# Sidekiq uses Redis to store all of its job and operational data.
# By default, Sidekiq tries to connect to Redis at localhost:6379
#
# You can also set the Redis url using environment variables.
# The generic REDIS_URL may be set to specify the Redis server.
#
# Otherwise it can be configured here using both the blocks
# Sidekiq.configure_server and Sidekiq.configure_client
#
# https://github.com/mperham/sidekiq/wiki/Using-Redis

Sidekiq.default_worker_options = { retry: 5 }
