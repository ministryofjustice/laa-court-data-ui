# frozen_string_literal: true

namespace :worker do
  desc 'Test if sidekiq process is running. raises error if not.'
  task healthcheck: :environment do
    raise StandardError if `pgrep -f sidekiq`.blank?
  end
end
