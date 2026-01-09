# frozen_string_literal: true

require_relative '../seed_helper'

SeedHelper.find_or_create_user(
  {
    email: 'caseworker@example.com',
    first_name: 'Casey',
    last_name: 'Worker',
    username: 'work-c',
    roles: %w[caseworker],
    feature_flags: %w[view_appeals]
  }
)

SeedHelper.find_or_create_user(
  {
    email: 'admin@example.com',
    first_name: 'Admin',
    last_name: 'Worker',
    username: 'work-a',
    roles: %w[admin],
    feature_flags: %w[view_appeals]
  }
)
