# frozen_string_literal: true

# GOVUK GDS design system helpers
# for producing markup of non-form
# related markup.
#
require 'gds_design_system_breadcrumb_builder'

module GovukDesignSystemHelper
  def govuk_page_title(title = nil, caption = nil)
    content_for :page_title, page_title(title, caption)

    content_for :page_heading do
      tag.h1(class: 'govuk-heading-xl') do
        page_heading(title, caption)
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

  def page_heading(title, caption)
    page_title_var = title || contextual_title
    return page_title_var if caption.nil?
    tag.span(caption, class: 'govuk-caption-xl').concat(page_title_var)
  end

  def page_title(title, caption)
    page_title_var = title || contextual_title
    caption_var = caption.strip.concat if caption.present?
    "#{caption_var} #{page_title_var} - #{service_name} - GOV.UK".strip
  end
end
