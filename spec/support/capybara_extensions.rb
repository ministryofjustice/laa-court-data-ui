# frozen_string_literal: true

# Extensions to capybara can be written here
# and they will be mixed into existing
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

    def has_govuk_breadcrumb?(text = nil, options = {})
      text ? options[:text] = text : options
      selector = options.delete(:aria_current) ? current_breadcrumb_selector : breadcrumb_selector

      has_selector?(selector, options)
    end

    def has_govuk_breadcrumb_link?(text = nil, options = {})
      text ? options[:text] = text : options
      has_selector?(breadcrumb_link_selector, options)
    end

    private

    def breadcrumb_selector
      'div.govuk-breadcrumbs ol.govuk-breadcrumbs__list li.govuk-breadcrumbs__list-item'
    end

    def current_breadcrumb_selector
      "#{breadcrumb_selector}[aria-current=\"page\"]"
    end

    def breadcrumb_link_selector
      "#{breadcrumb_selector} a.govuk-breadcrumbs__link"
    end
  end
end
