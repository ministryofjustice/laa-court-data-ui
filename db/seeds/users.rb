# frozen_string_literal: true

require_relative '../seed_helper'

SeedHelper.find_or_create_user(
  {
    email: 'caseworker@example.com',
    first_name: 'Casey',
    last_name: 'Worker',
    username: 'work-c',
    password: ENV.fetch('CASEWORKER_PASSWORD', nil),
    password_confirmation: ENV.fetch('CASEWORKER_PASSWORD', nil),
    roles: %w[caseworker],
    feature_flags: %w[view_appeals]
  }
)

SeedHelper.find_or_create_user(
  {
    email: 'manager@example.com',
    first_name: 'Mangy',
    last_name: 'Worker',
    username: 'work-m',
    password: ENV.fetch('MANAGER_PASSWORD', nil),
    password_confirmation: ENV.fetch('MANAGER_PASSWORD', nil),
    roles: %w[caseworker manager],
    feature_flags: %w[view_appeals]
  }
)

SeedHelper.find_or_create_user(
  {
    email: 'admin@example.com',
    first_name: 'Admin',
    last_name: 'Worker',
    username: 'work-a',
    password: ENV.fetch('ADMIN_PASSWORD', nil),
    password_confirmation: ENV.fetch('ADMIN_PASSWORD', nil),
    roles: %w[admin],
    feature_flags: %w[view_appeals]
  }
)
