# frozen_string_literal: true

# Seed required data
#

SEED_FILES = %w[
  users
  unlink_reasons
]

SEED_FILES.each do |file|
  file_path = "db/seeds/#{file}.rb"
  puts "loading #{file_path}..."
  load file_path
end
