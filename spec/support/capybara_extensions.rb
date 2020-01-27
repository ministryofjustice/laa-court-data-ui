# frozen_string_literal: true

# Extensions to capybara can be written here
# and they will be mixed into to existing
# helpers/matchers by the `spec/support/capybara.rb`
#
# Idea comes from:
# https://github.com/DavyJonesLocker/capybara-extensions
#
module CapybaraExtensions
  module Matchers
    def has_govuk_page_title?(options = {})
      has_selector?('h1.govuk-heading-xl', options)
    end

    def has_no_govuk_page_title?(options = {})
      has_no_selector?('h1.govuk-heading-xl', options)
    end
  end
end
