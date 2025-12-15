# frozen_string_literal: true

require_relative '../seed_helper'

SeedHelper.find_or_create_user(
  {
    email: 'caseworker@example.com',
    first_name: 'Casey',
    last_name: 'Worker',
    username: 'work-c',
    roles: %w[caseworker]
  }
)

SeedHelper.find_or_create_user(
  {
    email: 'manager@example.com',
    first_name: 'Mangy',
    last_name: 'Worker',
    username: 'work-m',
    roles: %w[caseworker manager]
  }
)

SeedHelper.find_or_create_user(
  {
    email: 'admin@example.com',
    first_name: 'Admin',
    last_name: 'Worker',
    username: 'work-a',
    roles: %w[admin]
  }
)
