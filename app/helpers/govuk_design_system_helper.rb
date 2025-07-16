# frozen_string_literal: true

# GOVUK GDS design system helpers
# for producing markup of non-form
# related markup.
#
require 'gds_design_system_breadcrumb_builder'

module GovukDesignSystemHelper
  def govuk_page_title(heading = nil, caption = nil, options = {})
    title = options.delete(:title)
    content_for :page_title, (title ? page_title(title) : page_title(heading, caption))

    content_for :page_heading do
      options = prepend_classes('govuk-heading-xl', options)
      tag.h1(**options) do
        page_heading(heading, caption)
      end
    end
  end

  def govuk_breadcrumb_builder
    GdsDesignSystemBreadcrumbBuilder
  end

  def govuk_detail(summary_text = nil, tag_options = {}, &)
    tag_options = prepend_classes('govuk-details', tag_options)
    tag_options[:data] = { module: 'govuk-details' }

    summary = tag.span(summary_text, class: 'govuk-details__summary-text')
    content = capture(&)
    tag.details(**tag_options) do
      concat tag.summary(summary, class: 'govuk-details__summary')
      concat tag.div(content, class: 'govuk-details__text')
    end
  end

  def govuk_summary_list_entry(key, value, tag_options_key = {}, tag_options_value = {})
    tag_class = prepend_classes('govuk-summary-list__row')
    tag_options_key = prepend_classes('govuk-summary-list__key', tag_options_key)
    tag_options_value = prepend_classes('govuk-summary-list__value', tag_options_value)

    tag.div(**tag_class) do
      govuk_summary_key(key, tag_options_key).concat(
        govuk_summary_value(value, tag_options_value)
      )
    end
  end

  def govuk_notification_banner(text = nil, key = 'Important', content = nil)
    type_role = govuk_notification_banner_role(key)
    type_class = govuk_notification_banner_extra_class(key)
    tag_options = govuk_notification_banner_tag_options(type_role, type_class)
    tag.div(**tag_options) do
      concat tag.div(govuk_notification_banner_title(key), class: 'govuk-notification-banner__header')
      concat tag.div(govuk_notification_banner_content(text, content),
                     class: 'govuk-notification-banner__content')
    end
  end

  private

  def govuk_notification_banner_tag_options(type_role, type_class)
    tag_options = prepend_classes("govuk-notification-banner #{type_class}")
    tag_options[:data] = { module: 'govuk-notification-banner' }
    tag_options[:role] = type_role
    tag_options[:aria] = { labelledby: 'govuk-notification-banner-title' }
    tag_options
  end

  def govuk_notification_banner_role(key)
    if %w[Success Failure].include?(key)
      'alert'
    else
      'region'
    end
  end

  def govuk_notification_banner_extra_class(key)
    type_class = 'govuk-notification-banner--success' if key == 'Success'
    type_class = 'govuk-notification-banner--failure' if key == 'Failure'
    type_class
  end

  def govuk_notification_banner_title(title)
    tag.h2(title, id: 'govuk-notification-banner-title', class: 'govuk-notification-banner__title')
  end

  def govuk_notification_banner_content(text, content)
    content_tag = tag.p(content, class: 'govuk-body') unless content.nil?
    tag.p(text, class: 'govuk-notification-banner__heading').concat(content_tag)
  end

  def govuk_summary_key(key, tag_options_key)
    tag.dt(**tag_options_key) do
      key
    end
  end

  def govuk_summary_value(value, tag_options_value)
    tag.dd(**tag_options_value) do
      value
    end
  end

  def prepend_classes(classes_to_prepend, options = {})
    classes = options[:class].present? ? options[:class].split : []
    classes.prepend(classes_to_prepend.split)
    options[:class] = classes.join(' ')
    options
  end

  def contextual_title
    [action_name.titleize, controller_name.downcase.singularize].join(' ')
  end

  def page_heading(title, caption)
    page_title_var = title || contextual_title
    return page_title_var if caption.nil?
    tag.span(caption, class: 'govuk-caption-xl').concat(page_title_var)
  end

  def page_title(title, caption = nil)
    page_title_var = title || contextual_title
    caption_var = caption.strip if caption.present?
    "#{caption_var} #{page_title_var} - #{service_name} - GOV.UK".strip
  end
end
