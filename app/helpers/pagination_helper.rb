# frozen_string_literal: true

module PaginationHelper
  include Pagy::Frontend

  def pagination_info(pagy, item_name)
    # Pagy's output is not marked as html_safe even though it _is_ safe, so
    # we explicitly mark it as such here
    # rubocop:disable Rails/OutputSafety
    pagy_info(pagy, item_name: item_name.downcase.pluralize(pagy.count)).html_safe
    # rubocop:enable Rails/OutputSafety
  end

  def mobile_pagination_series(pagy)
    current = pagy.page
    last = pagy.last

    [
      (1 if current > 1),
      (:gap if current > 2),
      current.to_s,
      (:gap if current < last - 1),
      (last if current < last)
    ].compact
  end

  def pagination_item_tag(item, pagy)
    case item
    when String
      tag.li(class: "govuk-pagination__item govuk-pagination__item--current") do
        tag.a(item, href: pagy_url_for(pagy, item.to_i),
                    class: "govuk-link govuk-pagination__link",
                    aria: { label: "Page #{item}", current: "page" })
      end
    when Integer
      tag.li(class: "govuk-pagination__item") do
        tag.a(item.to_s, href: pagy_url_for(pagy, item),
                         class: "govuk-link govuk-pagination__link",
                         aria: { label: "Page #{item}" })
      end
    when :gap then tag.li("⋯", class: "govuk-pagination__item govuk-pagination__item--ellipsis")
    end
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
end
