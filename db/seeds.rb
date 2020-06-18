# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require_relative 'seed_helper'

SeedHelper.find_or_create_user({
  email: 'caseworker@example.com',
  first_name: 'Casey',
  last_name: 'Worker',
  username: 'work-c',
  password: ENV.fetch('CASEWORKER_PASSWORD', nil),
  password_confirmation: ENV.fetch('CASEWORKER_PASSWORD', nil),
  roles: ['caseworker']
})

SeedHelper.find_or_create_user({
  email: 'manager@example.com',
  first_name: 'Mangy',
  last_name: 'Worker',
  username: 'work-m',
  password: ENV.fetch('MANAGER_PASSWORD', nil),
  password_confirmation: ENV.fetch('MANAGER_PASSWORD', nil),
  roles: ['caseworker', 'manager']
})

SeedHelper.find_or_create_user({
  email: 'admin@example.com',
  first_name: 'Admin',
  last_name: 'Worker',
  username: 'work-a',
  password: ENV.fetch('ADMIN_PASSWORD', nil),
  password_confirmation: ENV.fetch('ADMIN_PASSWORD', nil),
  roles: ['admin']
})