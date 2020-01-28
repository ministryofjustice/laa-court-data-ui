# frozen_string_literal: true

# Load custom capybara extensions
#
# Idea comes from:
# https://github.com/DavyJonesLocker/capybara-extensions
#
require_relative 'capybara_extensions'

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
