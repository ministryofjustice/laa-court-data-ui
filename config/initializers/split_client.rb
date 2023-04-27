# frozen_string_literal: true

require 'splitclient-rb'

RELOAD_RATE_IN_SECONDS = 60.seconds.to_i

if Rails.env.production?
  split_key = Rails.configuration.x.split_io.key
  factory = SplitIoClient::SplitFactoryBuilder.build(split_key, reload_rate: RELOAD_RATE_IN_SECONDS)
else
  factory = SplitIoClient::SplitFactoryBuilder.build(
    'localhost',
    split_file: 'config/split.yaml',
    reload_rate: RELOAD_RATE_IN_SECONDS
  )
end

Rails.configuration.split_factory = factory
Rails.configuration.split_client = factory.client
