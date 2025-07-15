# frozen_string_literal: true

require 'feature_flag'

module ApplicationHelper
  include GovukDesignSystemHelper
  include Pagy::Frontend

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

  def decorate_all(objects, decorator_class = nil, &)
    objects.map do |object|
      decorate(object, decorator_class, &)
    end
  end
  alias decorate_each decorate_all

  def hearings_sorter_link(prosecution_case, column, title = nil)
    title ||= prosecution_case.column_title(column)
    title = "#{title} " + prosecution_case.column_sort_icon if column == prosecution_case.hearings_sort_column
    direction = prosecution_case.hearings_sort_direction == 'asc' ? 'desc' : 'asc'
    link_to(title, prosecution_case_path(id: prosecution_case.prosecution_case_reference, column:, direction:, anchor: column), class: 'govuk-link govuk-link--no-visited-state', id: column, "aria-label": "Sort #{column} #{direction}")
  end

  def app_environment
    "app-environment-#{ENV.fetch('ENV', 'local')}"
  end

  def pagination_info(pagy, item_name)
    # Pagy's output is not marked as html_safe even though it _is_ safe, so
    # we explicitly mark it as such here
    # rubocop:disable Rails/OutputSafety
    pagy_info(pagy, item_name: item_name.downcase.pluralize(pagy.count)).html_safe
    # rubocop:enable Rails/OutputSafety
  end

  private

  def decorator_instance(object, decorator_class = nil)
    return object if object.is_a?(BaseDecorator)
    decorator_class ||= "#{object.class.to_s.demodulize}Decorator".constantize
    decorator_class.new(object, self)
  end
end
