# frozen_string_literal: true

module ApplicationHelper
  include GovukDesignSystemHelper

  def service_name
    'View court data'
  end

  def l(date, options = {})
    super(date, **options) if date
  end

  # NOTE: implicit decorators assumed to be in app/decorators
  def decorate(object, decorator_class = nil)
    decorator_class ||= "#{object.class.to_s.demodulize}Decorator".constantize
    decorator = decorator_class.new(object, self)

    yield(decorator) if block_given? && decorator.present?
    return nil if decorator.blank?

    decorator
  end

  def decorate_all(objects, decorator_class = nil, &block)
    objects.map do |object|
      decorate(object, decorator_class, &block)
    end
  end
  alias decorate_each decorate_all
end
