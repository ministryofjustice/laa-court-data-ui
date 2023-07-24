# frozen_string_literal: true

# Load custom capybara extensions
#
# Idea comes from:
# https://github.com/DavyJonesLocker/capybara-extensions
#
require 'capybara_table/rspec'
require_relative 'capybara_extensions'
require 'axe-rspec'

module Capybara
  module DSL
    CapybaraExtensions::Matchers.instance_methods.each do |method|
      define_method method do |*args, &block|
        page.send method, *args, &block
      end
    end
  end

  class Session
    CapybaraExtensions::Matchers.instance_methods.each do |method|
      define_method method do |*args, &block|
        current_scope.send method, *args, &block
      end
    end
  end

  Node::Base.include CapybaraExtensions::Matchers
  Node::Simple.include CapybaraExtensions::Matchers
end

Webdrivers::Chromedriver.required_version = "114.0.5735.90"

Capybara.configure do |config|
  # https://www.rubydoc.info/github/jnicklas/capybara/Capybara.configure
  config.automatic_label_click = true
  config.default_max_wait_time = 1
  config.javascript_driver = :selenium_chrome_headless
end
