# frozen_string_literal: true

require "feature_flag"

module ApplicationHelper
  include GovukDesignSystemHelper

  def service_name
    "View court data"
  end

  def l(date, options = {})
    super(date, **options) if date
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

  # Screen readers read the visually hidden spaced copy of an identifier (URN, ASN, ...)
  # character by character (e.g. "12345" as "1 2 3 4 5") rather than as a quantity ("twelve thousand...")
  def accessible_id(value, **options)
    return if value.blank?

    safe_join([
      tag.span(value, **options, aria: { hidden: true }),
      tag.span(value.to_s.chars.join(" "), class: "govuk-visually-hidden"),
    ])
  end

  def app_environment
    "app-environment-#{ENV.fetch('ENV', 'local')}"
  end

private

  def decorator_instance(object, decorator_class = nil)
    return object if object.is_a?(BaseDecorator)

    decorator_class ||= "#{object.class.to_s.demodulize}Decorator".constantize
    decorator_class.new(object, self)
  end
end
