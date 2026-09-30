# frozen_string_literal: true

require "feature_flag"

module ApplicationHelper
  include GovukDesignSystemHelper

  ACRONYM_PATTERN = /[A-Z]{2,}[0-9]*/

  def service_name
    "View court data"
  end

  def l(date, options = {})
    super(date, **options) if date
  end

  # Presents dates in two ways, a full version for screen readers and one for visual users. The screen reader version is
  # hidden from visual users, and the visual version is hidden from screen readers.
  def accessible_date(date, format: :default, **options)
    if date
      [
        tag.span(I18n.l(date, format: :long), class: "govuk-visually-hidden"),
        tag.span(I18n.l(date, format: format), **options, aria: { hidden: "true" }),
      ].join.html_safe
    end
  end

  # NOTE: implicit decorators assumed to be in app/decorators
  #
  def decorate(object, decorator_class = nil)
    decorator = decorator_instance(object, decorator_class)
    yield(decorator) if block_given? && decorator.present?
    return nil if decorator.blank?

    decorator
  end

  def decorate_all(objects, decorator_class = nil, &)
    objects.map do |object|
      decorate(object, decorator_class, &)
    end
  end
  alias_method :decorate_each, :decorate_all

  def navigation_item(path, label, active: current_page?(path))
    active_class = active ? " govuk-service-navigation__item--active" : ""

    tag.li(class: "govuk-service-navigation__item#{active_class}") do
      tag.a(class: "govuk-service-navigation__link", href: path, aria: (active ? { current: "true" } : {})) do
        active ? tag.strong(label, class: "govuk-service-navigation__active-fallback") : label
      end
    end
  end

  # Screen readers read the visually hidden spaced copy character by character rather than as a
  # word or a quantity.
  #
  # Identifiers (URN, ASN, MAAT reference, ...), which contain no lower case characters, are spelled
  # out in full, e.g. "12345" becomes "1 2 3 4 5".
  #
  # Free text only has its acronyms (two or more consecutive capital letters, optionally followed
  # by digits) spelled out, ie: "Link MAAT IDs" becomes "Link M A A T I Ds".
  # A trailing lower case plural stays attached to the last letter of the acronym.
  def accessible_text(value, **options)
    return if value.blank?

    safe_join([
      tag.span(value, **options, aria: { hidden: true }),
      tag.span(spell_out(value.to_s), class: "govuk-visually-hidden"),
    ])
  end

  def app_environment
    "app-environment-#{ENV.fetch('ENV', 'local')}"
  end

private

  def spell_out(text)
    spelled_out = if text.match?(/[a-z]/)
                    text.gsub(ACRONYM_PATTERN) { |acronym| acronym.chars.join(" ") }
                  else
                    text.chars.join(" ")
                  end

    text.html_safe? ? spelled_out.html_safe : spelled_out
  end

  def decorator_instance(object, decorator_class = nil)
    return object if object.is_a?(BaseDecorator)

    decorator_class ||= "#{object.class.to_s.demodulize}Decorator".constantize
    decorator_class.new(object, self)
  end
end
