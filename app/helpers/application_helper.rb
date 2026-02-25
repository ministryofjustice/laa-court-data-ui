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

  def navigation_item(path, label, active: current_page?(path))
    active_class = active ? " govuk-service-navigation__item--active" : ""

    tag.li(class: "govuk-service-navigation__item#{active_class}") do
      tag.a(class: "govuk-service-navigation__link", href: path, aria: (active ? { current: "true" } : {})) do
        active ? tag.strong(label, class: "govuk-service-navigation__active-fallback") : label
      end
    end
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

  def pagination_svg_icon(direction)
    # rubocop:disable Layout/LineLength
    prev_d = "m6.5938-0.0078125-6.7266 6.7266 6.7441 6.4062 1.377-1.449-4.1856-3.9768h12.896v-2h-12.984l4.2931-4.293-1.414-1.414z"
    next_d = "m8.107-0.0078125-1.4136 1.414 4.2926 4.293h-12.986v2h12.896l-4.1855 3.9766 1.377 1.4492 6.7441-6.4062-6.7246-6.7246z"
    # rubocop:enable Layout/LineLength
    path_d = direction == :prev ? prev_d : next_d
    content_tag(:svg,
                content_tag(:path, '', d: path_d),
                class: "govuk-pagination__icon govuk-pagination__icon--#{direction}",
                xmlns: "http://www.w3.org/2000/svg",
                height: "13", width: "15",
                focusable: "false",
                aria: { hidden: "true" },
                viewBox: "0 0 15 13")
  end

  private

  def decorator_instance(object, decorator_class = nil)
    return object if object.is_a?(BaseDecorator)
    decorator_class ||= "#{object.class.to_s.demodulize}Decorator".constantize
    decorator_class.new(object, self)
  end
end
