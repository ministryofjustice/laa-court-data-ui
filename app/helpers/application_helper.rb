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
  #
  def decorate(object, decorator_class = nil)
    decorator = decorator_instance(object, decorator_class)
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

  def hearings_sorter_link(id, column, title = nil)
    title ||= column_title(column)
    title = column == sort_column ? ("#{title} " + column_sort_icon) : title
    direction = sort_direction == 'asc' ? 'desc' : 'asc'
    link_to(title, prosecution_case_path(id: id, column: column, direction: direction), class: 'govuk-link')
  end

  private

  def decorator_instance(object, decorator_class = nil)
    return object if object.is_a?(BaseDecorator)

    decorator_class ||= "#{object.class.to_s.demodulize}Decorator".constantize
    decorator_class.new(object, self)
  end

  def column_sort_icon
    sort_direction == 'asc' ? "\u25B2" : "\u25BC"
  end

  def column_title(column)
    case column
    when 'type'
      t('search.result.hearing.hearing_type')
    when 'provider'
      t('search.result.hearing.providers')
    else
      t('search.result.hearing.hearing_day')
    end
  end
end
