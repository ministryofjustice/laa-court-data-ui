# frozen_string_literal: true

# GOVUK GDS design system helpers
# for producing markup of non-form
# related markup.
#
require 'gds_design_system_breadcrumb_builder'

module GovukDesignSystemHelper
  def govuk_page_title(title = nil)
    content_for :page_title, (title || contextual_title) + " - #{service_name} - GOV.UK"

    content_for :page_heading do
      tag.h1(class: 'govuk-heading-xl') do
        title || contextual_title
      end
    end
  end

  def govuk_breadcrumb_builder
    GdsDesignSystemBreadcrumbBuilder
  end

  private

  def contextual_title
    [action_name.titleize, controller_name.downcase.singularize].join(' ')
  end
end
