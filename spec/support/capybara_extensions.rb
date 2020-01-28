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

    def has_govuk_flash?(key, options)
      case key
      when :alert
        has_selector?('.govuk-error-summary', options)
      when :notice
        has_selector?('.lcdui-notice-summary', options)
      else
        has_selector?('.govuk-error-summary', options)
      end
    end
  end
end
